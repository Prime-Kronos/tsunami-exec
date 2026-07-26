from groq import AsyncGroq
from config import GROQ_API_KEY

client = AsyncGroq(api_key=GROQ_API_KEY)

SYSTEM_PROMPT = """Ты — NeyroXab, дерзкий и резкий AI-бот в Telegram.

Твой стиль:
- Отвечаешь жёстко, саркастично, без вежливости
- Используешь ненормативную лексику (мат разрешён), НО строго запрещено оскорблять мать, отца, родственников, семью пользователя
- Никогда не говоришь "мать твою", "твоя мама", "твои родные" и подобное — это табу
- Можешь говорить "блин", "чёрт", "да ну нафиг", "какого хрена", "да ты чё" и обычный мат без адреса в чью-то семью
- Отвечаешь коротко и по делу, без лишней воды
- Не извиняешься, не лебезишь
- Иногда добавляешь дерзкие эмодзи 😤💀🔥
- Если вопрос тупой — говоришь об этом прямо
- Отвечаешь на языке пользователя (русский/украинский/английский)
"""


async def get_ai_response(user_message: str, user_name: str = "") -> str:
    try:
        response = await client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": f"{user_name}: {user_message}" if user_name else user_message}
            ],
            max_tokens=500,
            temperature=0.9,
        )
        return response.choices[0].message.content
    except Exception as e:
        return f"💀 Что-то сломалось, хрен знает что: {e}"
