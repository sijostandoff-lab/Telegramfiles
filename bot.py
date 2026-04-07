import asyncio
import sqlite3
import logging
from aiogram import Bot, Dispatcher, Router, types
from aiogram.types import Message, ReplyKeyboardMarkup, KeyboardButton
from aiogram.filters import Command, CommandStart, CommandObject
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup

# ================= НАСТРОЙКИ (ОБЯЗАТЕЛЬНО ЗАПОЛНИ) =================
BOT_TOKEN = "8693534383:AAEM2Ql3WfX4iHrBOTAmBSKWNSpViYXuH2I"
BOT_USERNAME = "piskisliv_bot" # без @
ADMIN_ID = 8747396295  # Твой реальный ID (узнай его у @getmyid_bot)
# =================================================================

# Включаем логирование, чтобы видеть ошибки в консоли
logging.basicConfig(level=logging.INFO)

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()
router = Router()

# База данных
conn = sqlite3.connect('piski_files.db', check_same_thread=False)
cursor = conn.cursor()
cursor.execute('CREATE TABLE IF NOT EXISTS bundles (id INTEGER PRIMARY KEY AUTOINCREMENT)')
cursor.execute('CREATE TABLE IF NOT EXISTS messages (id INTEGER PRIMARY KEY AUTOINCREMENT, bundle_id INTEGER, from_chat_id INTEGER, message_id INTEGER)')
conn.commit()

class AdminState(StatesGroup):
    uploading_files = State()

# Кнопки для админа
def get_admin_kb():
    buttons = [
        [KeyboardButton(text="/admingetlink")],
        [KeyboardButton(text="/done"), KeyboardButton(text="/cancel")]
    ]
    return ReplyKeyboardMarkup(keyboard=buttons, resize_keyboard=True)

# 1. ОБНОВЛЕННЫЙ /START
@router.message(CommandStart())
async def cmd_start(message: Message, command: CommandObject, state: FSMContext):
    args = command.args
    
    # Если это админ - даем ему кнопки управления
    if message.from_user.id == ADMIN_ID:
        if not args:
            return await message.answer(
                "👋 Привет, Админ! Бот работает.\nИспользуй кнопку ниже, чтобы начать создание мульти-ссылки.",
                reply_markup=get_admin_kb()
            )

    # Если юзер перешел по ссылке (начинается на b_)
    if args and args.startswith("b_"):
        bundle_id = args.split("_")[1]
        cursor.execute("SELECT from_chat_id, message_id FROM messages WHERE bundle_id = ? ORDER BY id ASC", (bundle_id,))
        results = cursor.fetchall()

        if results:
            await message.answer("⏳ Начинаю отправку файлов...")
            for f_chat, m_id in results:
                try:
                    await bot.copy_message(message.chat.id, f_chat, m_id)
                    await asyncio.sleep(0.2)
                except Exception: continue
            await message.answer("✅ Готово!")
        else:
            await message.answer("❌ Ссылка недействительна или пуста.")
    else:
        await message.answer("Бот Piski Files в сети ⚡️\nЖду твою ссылку на медиа.")

# 2. ИСПРАВЛЕННЫЙ /admingetlink
@router.message(Command("admingetlink"))
async def cmd_admin_get_link(message: Message, state: FSMContext):
    # Проверка на админа (если не работает, значит ID не совпадает)
    if message.from_user.id != ADMIN_ID:
        return await message.answer(f"У тебя нет прав. Твой ID: {message.from_user.id}")
    
    cursor.execute("INSERT INTO bundles DEFAULT VALUES")
    bundle_id = cursor.lastrowid
    conn.commit()

    await state.set_state(AdminState.uploading_files)
    await state.update_data(bundle_id=bundle_id)
    
    await message.answer(
        "📥 **РЕЖИМ ЗАГРУЗКИ АКТИВИРОВАН**\n\n"
        "Теперь просто кидай сюда файлы (фото, видео, кружочки).\n"
        "Как закончишь — нажми кнопку или напиши **/done**.",
        parse_mode="Markdown",
        reply_markup=get_admin_kb()
    )

# 3. Прием файлов
@router.message(AdminState.uploading_files, ~Command("done"), ~Command("cancel"))
async def catch_files(message: Message, state: FSMContext):
    data = await state.get_data()
    bundle_id = data.get("bundle_id")
    
    cursor.execute("INSERT INTO messages (bundle_id, from_chat_id, message_id) VALUES (?, ?, ?)", 
                   (bundle_id, message.chat.id, message.message_id))
    conn.commit()

# 4. Завершение загрузки
@router.message(Command("done"), AdminState.uploading_files)
async def cmd_done(message: Message, state: FSMContext):
    data = await state.get_data()
    bundle_id = data.get("bundle_id")
    
    cursor.execute("SELECT COUNT(*) FROM messages WHERE bundle_id = ?", (bundle_id,))
    count = cursor.fetchone()[0]

    if count > 0:
        link = f"https://t.me/{BOT_USERNAME}?start=b_{bundle_id}"
        await message.answer(
            f"✅ **Ссылка готова!**\nЗагружено элементов: {count}\n\n`{link}`",
            parse_mode="Markdown"
        )
    else:
        await message.answer("Ничего не было загружено.")
    
    await state.clear()

# 5. Отмена
@router.message(Command("cancel"), AdminState.uploading_files)
async def cmd_cancel(message: Message, state: FSMContext):
    await state.clear()
    await message.answer("❌ Загрузка отменена.")

async def main():
    dp.include_router(router)
    print("--- БОТ ЗАПУЩЕН ---")
    await dp.start_polling(bot)

if __name__ == '__main__':
    asyncio.run(main())
