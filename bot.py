import asyncio
import sqlite3
from aiogram import Bot, Dispatcher, Router
from aiogram.types import Message
from aiogram.filters import Command, CommandStart, CommandObject
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup

# ================= НАСТРОЙКИ =================
BOT_TOKEN = "8693534383:AAEM2Ql3WfX4iHrBOTAmBSKWNSpViYXuH2I"
BOT_USERNAME = "piskisliv_bot" # БЕЗ @ (например: piskifiles_bot)
ADMIN_ID = 8747396295 # ТВОЙ TELEGRAM ID (только ты сможешь добавлять посты)
# =============================================

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()
router = Router()

# Настройка базы данных
conn = sqlite3.connect('piski_files.db')
cursor = conn.cursor()
cursor.execute('''
    CREATE TABLE IF NOT EXISTS posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        from_chat_id INTEGER,
        message_id INTEGER
    )
''')
conn.commit()

# Состояния для админа
class AdminState(StatesGroup):
    waiting_for_posts = State()

# Команда для включения режима загрузки
@router.message(Command("admingetlink"))
async def cmd_admin_get_link(message: Message, state: FSMContext):
    if message.from_user.id != ADMIN_ID:
        return
    await state.set_state(AdminState.waiting_for_posts)
    await message.answer(
        "📥 **Режим загрузки активирован.**\n\n"
        "Отправьте мне любые сообщения (кружки, фото, видео, голосовые, текст).\n"
        "На каждое я выдам уникальную ссылку.\n\n"
        "Для завершения отправьте /stop",
        parse_mode="Markdown"
    )

# Команда для выхода из режима загрузки
@router.message(Command("stop"), AdminState.waiting_for_posts)
async def cmd_stop(message: Message, state: FSMContext):
    await state.clear()
    await message.answer("🛑 Режим добавления постов выключен.")

# Ловец сообщений от админа (когда включен режим загрузки)
@router.message(AdminState.waiting_for_posts)
async def save_post(message: Message):
    # Сохраняем ID сообщения и ID чата админа
    cursor.execute(
        "INSERT INTO posts (from_chat_id, message_id) VALUES (?, ?)", 
        (message.chat.id, message.message_id)
    )
    conn.commit()
    post_id = cursor.lastrowid

    # Формируем deep-link ссылку
    link = f"https://t.me/{BOT_USERNAME}?start=post_{post_id}"
    await message.reply(f"✅ **Пост сохранен!**\n🔗 Ссылка: {link}\n\nЖду следующий файл или /stop", parse_mode="Markdown")

# Ловец команды /start с параметром (когда юзер переходит по ссылке)
@router.message(CommandStart())
async def cmd_start(message: Message, command: CommandObject):
    args = command.args
    
    # Если юзер перешел по ссылке с параметром post_...
    if args and args.startswith("post_"):
        post_id = args.split("_")[1]
        try:
            post_id = int(post_id)
        except ValueError:
            return await message.answer("❌ Неверная ссылка.")

        cursor.execute("SELECT from_chat_id, message_id FROM posts WHERE id = ?", (post_id,))
        result = cursor.fetchone()

        if result:
            from_chat_id, message_id = result
            try:
                # Копируем сообщение админа юзеру один в один
                await bot.copy_message(
                    chat_id=message.chat.id,
                    from_chat_id=from_chat_id,
                    message_id=message_id
                )
            except Exception as e:
                await message.answer("❌ Ошибка при отправке поста. Возможно, исходник был удален.")
        else:
            await message.answer("❌ Пост не найден.")
    else:
        # Обычный старт без параметров
        await message.answer("Привет! Я бот piski files 📁\nПерейди по специальной ссылке, чтобы получить медиа или файл.")

async def main():
    dp.include_router(router)
    print("Бот успешно запущен!")
    await dp.start_polling(bot)

if __name__ == '__main__':
    asyncio.run(main())
