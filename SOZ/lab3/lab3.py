from telethon.sync import TelegramClient, events
from telethon.tl.functions.channels import GetFullChannelRequest
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import re
import requests
from bs4 import BeautifulSoup

print("Кучерявий Максим КН-1-3М лабораторна 3")

hash = '#скорострільність'


def split_weapons(s):
    pattern = r'([A-Za-z0-9 &\-]+?)\s*:\s*(\d+)'
    matches = re.findall(pattern, s)
    
    # Якщо пар дві, повертаємо їх як два рядки

    return (f"{matches[0][0].strip()} : {matches[0][1]}", f"{matches[1][0].strip()} : {matches[1][1]}")

def formatWepon(wepon):
    split = wepon.split(" : ")
    return {
        "name": split[0],
        "speed": int(split[1])
    }

with TelegramClient('name', 22845409, '89cd9a726ee1fc1c7835d361cd7f65ae') as client:

    channel = client.get_entity('t.me/lab3Kucheriaviy')
    full_channel = client(GetFullChannelRequest(channel))


# зчитування власного каналу
    print(f'ID: {channel.id}')
    print(f'Username: {channel.username}')
    print(f'Назва (заголовок): {channel.title}')
    print(f'Дата створення: {channel.date}')

    fullText = ""

    for msg in client.iter_messages(channel, limit=5):
        text = msg.text or ''
        datetime_str = msg.date.strftime('%Y-%m-%d %H:%M:%S')
        char_count = len(text)
        word_count = len(text.split())
        fullText += f'{datetime_str} {text}\n\n'

        print(f'Дата і час: {datetime_str}')
        print(f'Зміст: {text}')
        print(f'Кількість символів: {char_count}')
        print(f'Кількість слів: {word_count}')
        print("---------------------------------")

    file = open("./text.txt", 'w', encoding='utf-8')
    file.write(fullText)


    infoChnal = client.get_entity('t.me/kn_nuft_tg')

    infoText = ""
# зчитування тестового каналу
    for msg in client.iter_messages(infoChnal):
        text = msg.text or ''
        char_count = len(text)
        word_count = len(text.split())

        if hash in text:
            infoText += text
    
    arr = infoText.split('\n')
    filteredArr = [x for x in arr if x != '' and x != hash]

    arr = []
    for line in filteredArr:
        if line.count(':') == 2:
            s = split_weapons(line)
            arr.append(formatWepon(s[0]))
            arr.append(formatWepon(s[1]))
        else:
            arr.append(formatWepon(line))
    print(arr)

    df = pd.DataFrame(arr)

    plt.figure(figsize=(12, 6))
    sns.barplot(data=df, x="name", y="speed", palette="viridis")

    plt.xticks(rotation=45, ha='right')

    plt.title("Швидкість кулі у різних моделях зброї")
    plt.xlabel("Модель зброї")
    plt.ylabel("Швидкість (м/с)")
    plt.tight_layout()

    plt.show()


# HTML парсинг
    response = requests.get('http://pol.ho.ua/soz2025.htm')
    html = response.text
    htmlText = BeautifulSoup(html, 'html.parser')
    print("html текст")
    print(htmlText)
    print("\n\n")
    print("підкреслений текст")
    for text in htmlText.find_all('u'):
        print(text.get_text(strip=True))
    print("\n\n")

    cellText = []
    headers = []
    result = []
    for table in htmlText.find_all('table'):
        if "Кучерявий" in table.get_text():
            for row in table.find_all('tr'):
                for cell in row.find_all(['td', 'th']):
                    text = cell.get_text(strip=True)
                    if text != "":
                        cellText.append(text)
                for header in row.find_all('strong'):
                    headers.append(header.get_text(strip=True))
    print("Всі комірки")
    print(cellText)
    print("\n\n")

    for text in cellText:
        if not text in headers:
            result.append(text)
    
    print("Всі комірки без заголовків")
    print(result)
    print("\n\n")

