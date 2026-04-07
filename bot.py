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


def load_posts():
    try:
        with open(POSTS_FILE, "r") as f:
            return json.load(f)
    except:
        return {}


def save_posts(data):
    with open(POSTS_FILE, "w") as f:
        json.dump(data, f)


posts = load_posts()


@dp.message(Command("start"))
async def start(message: Message):

    args = message.text.split(" ")

    if len(args) > 1 and args[1].startswith("post_"):

        post_id = args[1].split("_")[1]

        if post_id in posts:

            data = posts[post_id]

            if data["type"] == "photo":
                await message.answer_photo(data["file_id"], caption=data.get("text"))

            elif data["type"] == "video":
                await message.answer_video(data["file_id"], caption=data.get("text"))

            elif data["type"] == "voice":
                await message.answer_voice(data["file_id"])

            elif data["type"] == "video_note":
                await message.answer_video_note(data["file_id"])

            elif data["type"] == "document":
                await message.answer_document(data["file_id"])

            elif data["type"] == "text":
                await message.answer(data["text"])

        else:
            await message.answer("Пост не найден")


@dp.message(Command("admingetlink"))
async def link(message: Message):

    if not message.reply_to_message:
        await message.reply("Ответь на пост")
        return

    msg = message.reply_to_message
    post_id = str(len(posts) + 1)

    data = {}

    if msg.photo:
        data = {"type": "photo", "file_id": msg.photo[-1].file_id, "text": msg.caption}

    elif msg.video:
        data = {"type": "video", "file_id": msg.video.file_id, "text": msg.caption}

    elif msg.voice:
        data = {"type": "voice", "file_id": msg.voice.file_id}

    elif msg.video_note:
        data = {"type": "video_note", "file_id": msg.video_note.file_id}

    elif msg.document:
        data = {"type": "document", "file_id": msg.document.file_id}

    elif msg.text:
        data = {"type": "text", "text": msg.text}

    else:
        await message.reply("Тип не поддерживается")
        return

    posts[post_id] = data
    save_posts(posts)

    bot_info = await bot.get_me()

    link = f"https://t.me/{bot_info.username}?start=post_{post_id}"

    await message.reply(link)


async def main():
    await dp.start_polling(bot)


if __name__ == "__main__":
    asyncio.run(main())