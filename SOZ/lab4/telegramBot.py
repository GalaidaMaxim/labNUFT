from chatterbot import ChatBot
from chatterbot.trainers import ChatterBotCorpusTrainer
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes, MessageHandler, filters
import random
import re

def checkLine(s: str) -> bool:
    return bool(re.fullmatch(r"[0-9 ]*", s)) and bool(re.search(r"[0-9]", s))

def mathFunction(s: str) -> str:
    numbers = list(map(int, s.split()))
    avg = sum(numbers) / len(numbers)
    return " ".join(str(num) for num in numbers if num > avg)

nose_questions = [
    "Wie sieht deine Nase aus?",
    "Hast du eine große oder kleine Nase?",
    "Ist deine Nase gerade oder etwas gebogen?",
    "Fühlst du deine Nase oft?",
    "Hast du manchmal eine laufende Nase?",
    "Wie oft putzt du dir die Nase?",
    "Magst du deine Nase?",
    "Hast du schon mal an deiner Nase operiert?",
    "Riechst du gerne Blumen oder andere Düfte?",
    "Wie empfindlich ist deine Nase für Gerüche?",
    "Wann hast du das letzte Mal eine Nasebluten gehabt?",
    "Fällt dir deine Nase beim Sport manchmal zu?",
    "Hast du Allergien, die deine Nase beeinflussen?",
    "Wie pflegst du deine Nase im Winter?",
    "Hast du eine besondere Erinnerung mit deiner Nase?",
    "Fühlst du, wenn deine Nase kalt wird?",
    "Wie reagiert deine Nase auf scharfes Essen?",
    "Hast du jemals Nasenpiercing gehabt?",
    "Wie findest du die Form von Nasen bei anderen Menschen?",
    "Würdest du etwas an deiner Nase ändern wollen?"
]

# Створення бота
germanBot = ChatBot(
    'GermanBot',
    read_only=True,
    logic_adapters=[
        "chatterbot.logic.BestMatch"
    ]
)

trainer = ChatterBotCorpusTrainer(germanBot)
trainer.train("chatterbot.corpus.german")

users = []

def clearUserId(id):
    global users
    users = [uid for uid in users if uid != id]

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.effective_user.id
    clearUserId(user_id)
    await update.message.reply_text("Hallo, ich bin ein Bot, entwickelt von Maksym Kucheryavim")

async def topic(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.effective_user.id
    clearUserId(user_id)
    answer = germanBot.get_response(random.choice(nose_questions))
    await update.message.reply_text(f"{answer}")

async def math(update: Update, context: ContextTypes.DEFAULT_TYPE):
    global users
    user_id = update.effective_user.id
    await update.message.reply_text('Geben Sie Zahlen durch Leerzeichen getrennt ein.')
    users.append(user_id)


async def onMessage(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.effective_user.id
    text = update.message.text
    text = " ".join(text.split())
    if not checkLine(text):
        await update.message.reply_text("Ungültige Zeichenfolge")
    else:
        await update.message.reply_text(mathFunction(text))

    clearUserId(user_id)

def main():
    app = ApplicationBuilder().token("7659872220:AAFIIsTmR6-zMdH90bP9Wl5U6VonjqtnwI8").build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("topic", topic))
    app.add_handler(CommandHandler("math", math))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, onMessage))
    app.run_polling()

main()