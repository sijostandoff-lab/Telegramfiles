import asyncio
import json
from aiogram import Bot, Dispatcher, types
from aiogram.filters import Command, CommandStart
from aiogram.types import Message

TOKEN = "8760199710:AAFMoZzhFxRE1Vv0TZPZGjD-eqWazTKeal4"
ADMIN_ID = 8489998847  # Твой Telegram ID для получения сообщений и ответов

bot = Bot(token=TOKEN)
dp = Dispatcher()

DB_FILE = "db.json"

# --- Работа с базой ---
def load_db():
    with open(DB_FILE, "r", encoding="utf-8") as f:
        return json.load(f)

def save_db(data):
    with open(DB_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

# --- Команда /start ---
@dp.message(CommandStart())
async def start(message: Message):
    await message.answer("Привет! Отправь мне своё сообщение, я передам его админу.")

# --- Приём сообщений от пользователей ---
@dp.message()
async def user_feedback(message: Message):
    if message.from_user.id == ADMIN_ID:
        return  # админ не отправляет фидбек сам себе

    db = load_db()
    feedback_id = len(db["feedbacks"]) + 1
    db["feedbacks"].append({
        "id": feedback_id,
        "user_id": message.from_user.id,
        "username": message.from_user.username,
        "text": message.text
    })
    save_db(db)

    # уведомление админа
    await bot.send_message(
        ADMIN_ID,
        f"Новое сообщение #{feedback_id} от @{message.from_user.username or message.from_user.id}:\n\n{message.text}"
    )
    await message.answer("Спасибо! Твоё сообщение отправлено админу.")

# --- Команда /reply <id> <текст> для админа ---
@dp.message(Command(commands=["reply"]))
async def reply_feedback(message: Message):
    if message.from_user.id != ADMIN_ID:
        await message.answer("Ты не админ!")
        return

    try:
        parts = message.text.split(" ", 2)
        feedback_id = int(parts[1])
        reply_text = parts[2]
    except (IndexError, ValueError):
        await message.answer("Использование: /reply <id> <текст>")
        return

    db = load_db()
    feedback = next((f for f in db["feedbacks"] if f["id"] == feedback_id), None)
    if not feedback:
        await message.answer("Сообщение с таким ID не найдено.")
        return

    await bot.send_message(feedback["user_id"], f"Админ ответил:\n\n{reply_text}")
    await message.answer("Ответ отправлен!")

# --- Запуск бота ---
async def main():
    print("Бот запущен...")
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())