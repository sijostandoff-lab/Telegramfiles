import json
import asyncio
from aiogram import Bot, Dispatcher, F
from aiogram.types import Message
from aiogram.filters import Command
from aiogram.client.default import DefaultBotProperties

TOKEN = "8693534383:AAEM2Ql3WfX4iHrBOTAmBSKWNSpViYXuH2I"

bot = Bot(TOKEN, default=DefaultBotProperties(parse_mode="HTML"))
dp = Dispatcher()

POSTS_FILE = "posts.json"

posts = {}
upload_buffer = []
collect_mode = False


def load_posts():
    try:
        with open(POSTS_FILE, "r") as f:
            return json.load(f)
    except:
        return {}


def save_posts():
    with open(POSTS_FILE, "w") as f:
        json.dump(posts, f)


posts = load_posts()


# START
@dp.message(Command("start"))
async def start(message: Message):

    args = message.text.split(" ")

    if len(args) > 1 and args[1].startswith("post_"):

        post_id = args[1].split("_")[1]

        if post_id in posts:

            for msg in posts[post_id]:
                await bot.copy_message(
                    chat_id=message.chat.id,
                    from_chat_id=msg["chat_id"],
                    message_id=msg["message_id"]
                )

        else:
            await message.answer("Файлы не найдены")

    else:

        await message.answer(
            "📁 Добро пожаловать в piski files.\n\n"
            "Этот бот используется для получения файлов по ссылкам."
        )


# начать загрузку
@dp.message(Command("admingetlink"))
async def start_collect(message: Message):

    global upload_buffer, collect_mode

    upload_buffer = []
    collect_mode = True

    await message.answer(
        "📤 Ожидаю файлы.\n"
        "Отправьте один или несколько сообщений."
    )


# создать ссылку
@dp.message(Command("adminmakelink"))
async def make_link(message: Message):

    global upload_buffer, collect_mode

    if not upload_buffer:
        await message.answer("❌ Вы не отправили файлы")
        return

    post_id = str(len(posts) + 1)

    posts[post_id] = upload_buffer
    save_posts()

    bot_info = await bot.get_me()
    link = f"https://t.me/{bot_info.username}?start=post_{post_id}"

    upload_buffer = []
    collect_mode = False

    await message.answer(f"✅ Ссылка создана:\n{link}")


# сбор файлов
@dp.message()
async def collect_files(message: Message):

    global upload_buffer, collect_mode

    if not collect_mode:
        return

    if message.text and message.text.startswith("/"):
        return

    upload_buffer.append({
        "chat_id": message.chat.id,
        "message_id": message.message_id
    })

    await message.answer(
        "📦 Файл добавлен.\n"
        "Когда закончите отправку используйте /adminmakelink"
    )


async def main():
    await dp.start_polling(bot)


if __name__ == "__main__":
    asyncio.run(main())