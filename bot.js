const { Telegraf } = require("telegraf")

const BOT_TOKEN = "8694629158:AAGaga2-MI6ZWOvcNLuVlXLWWxsWM8DqQ8A"
const ADMIN_ID = 8489998847 // твой Telegram ID

const bot = new Telegraf(BOT_TOKEN)

// старт
bot.start((ctx) => {
    ctx.reply("📩 Добро пожаловать в piski предложку\n\nОтправь сообщение, фото, видео или стикер — оно попадёт администратору.")
})

// пересылка сообщений админу
bot.on("message", async (ctx) => {

    // если сообщение от админа — пропускаем
    if (ctx.from.id == ADMIN_ID) return

    const userId = ctx.from.id
    const username = ctx.from.username || "без username"

    // пересылаем сообщение
    const msg = await ctx.forwardMessage(ADMIN_ID)

    // добавляем кнопку ответа
    await ctx.telegram.sendMessage(
        ADMIN_ID,
        `📨 Новое сообщение\n\n👤 @${username}\n🆔 ${userId}`,
        {
            reply_to_message_id: msg.message_id
        }
    )
})

// ответ админа
bot.on("reply_to_message", async (ctx) => {

    if (ctx.from.id !== ADMIN_ID) return

    const replied = ctx.message.reply_to_message

    if (!replied.forward_from) return

    const userId = replied.forward_from.id

    try {
        await ctx.copyMessage(userId)
        await ctx.reply("✅ Ответ отправлен")
    } catch {
        ctx.reply("❌ Не удалось отправить")
    }
})

bot.launch()

console.log("piski предложка бот запущен")