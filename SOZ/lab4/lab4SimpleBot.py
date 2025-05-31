from chatterbot import ChatBot
from chatterbot.trainers import ListTrainer


small_talk = [
    "Hi! How’s it going?",
    "Nice weather today, isn’t it?",
    "Did you have a good weekend?",
    "What do you do for a living?",
    "Where are you from originally?",
    "Have you been here before?",
    "This is a nice place, isn’t it?",
    "How do you know the host?",
    "Are you working on anything exciting right now?",
    "What do you like to do in your free time?",
    "Have you watched anything good lately?",
    "Read any interesting books recently?",
    "I love your outfit! Where did you get it?",
    "Do you like to travel?",
    "Been on any trips lately?",
    "How was your day?",
    "Do you have any weekend plans?",
    "Do you come here often?",
    "It’s been a crazy week, hasn’t it?",
    "The traffic was terrible today.",
    "What kind of music do you listen to?",
    "Do you play any sports or go to the gym?",
    "Have you tried that new restaurant in town?",
    "How do you usually spend your evenings?",
    "That’s interesting — tell me more.",
    "How do you usually start your day?",
    "Any recommendations for movies or shows?",
    "Do you work remotely or go to the office?",
    "What kind of food do you like?",
    "It was great talking with you!"
]

myBot = ChatBot(
    name="PyBot",
    read_only=True,
    logic_adapters=[
        "chatterbot.logic.MathematicalEvaluation",
        "chatterbot.logic.BestMatch"
    ]
)

trainList = ListTrainer(myBot)

trainList.train(small_talk)


for i in range(10):
    line = input("->")
    answer = myBot.get_response(line)
    print("Pitonik:", answer)