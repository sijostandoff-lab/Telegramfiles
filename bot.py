import json
from aiogram import Bot, Dispatcher, types
from aiogram.utils import executor

TOKEN = "8693534383:AAEM2Ql3WfX4iHrBOTAmBSKWNSpViYXuH2I"

bot = Bot(token=TOKEN)
dp = Dispatcher(bot)

POSTS_FILE = "posts.json"

# загрузка базы
def load_posts():
    try:
        with open(POSTS_FILE, "r") as f:
            return json.load(f)
    except:
        return {}

# сохранение базы
def save_posts(data):
    with open(POSTS_FILE, "w") as f:
        json.dump(data, f)

posts = load_posts()


# /start
@dp.message_handler(commands=['start'])
async def start(message: types.Message):
    args = message.get_args()

    if args.startswith("post_"):
        post_id = args.split("_")[1]

        if post_id in posts:
            file_id = posts[post_id]["file_id"]
            file_type = posts[post_id]["type"]
            text = posts[post_id].get("text")

            if file_type == "photo":
                await message.answer_photo(file_id, caption=text)

            elif file_type == "video":
                await message.answer_video(file_id, caption=text)

            elif file_type == "voice":
                await message.answer_voice(file_id)

            elif file_type == "video_note":
                await message.answer_video_note(file_id)

            elif file_type == "document":
                await message.answer_document(file_id)

            elif file_type == "text":
                await message.answer(text)

            else:
                await message.answer("Неизвестный тип файла")

        else:
            await message.answer("Пост не найден")


# команда получения ссылки
@dp.message_handler(commands=["admingetlink"])
async def get_link(message: types.Message):

    if not message.reply_to_message:
        await message.reply("Ответь на сообщение с медиа")
        return

    msg = message.reply_to_message
    post_id = str(len(posts) + 1)

    data = {}

    if msg.photo:
        data = {
            "type": "photo",
            "file_id": msg.photo[-1].file_id,
            "text": msg.caption
        }

    elif msg.video:
        data = {
            "type": "video",
            "file_id": msg.video.file_id,
            "text": msg.caption
        }

    elif msg.voice:
        data = {
            "type": "voice",
            "file_id": msg.voice.file_id
        }

    elif msg.video_note:
        data = {
            "type": "video_note",
            "file_id": msg.video_note.file_id
        }

    elif msg.document:
        data = {
            "type": "document",
            "file_id": msg.document.file_id
        }

    elif msg.text:
        data = {
            "type": "text",
            "text": msg.text
        }

    else:
        await message.reply("Тип медиа не поддерживается")
        return

    posts[post_id] = data
    save_posts(posts)

    link = f"https://t.me/{(await bot.get_me()).username}?start=post_{post_id}"

    await message.reply(f"Ссылка:\n{link}")


# загрузка постов напрямую
@dp.message_handler(content_types=types.ContentTypes.ANY)
async def upload(message: types.Message):
    await message.reply(
        "Чтобы получить ссылку на пост, ответь на него командой:\n/admingetlink"
    )


if __name__ == "__main__":
    executor.start_polling(dp)