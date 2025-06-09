import hashlib

def ensure_utf8(text):
    if isinstance(text, str):
        try:
            # Пробуем декодировать как UTF-8
            text.encode('utf-8')
            return text
        except UnicodeEncodeError:
            # Если не получилось, пробуем разные варианты декодирования
            try:
                # Пробуем как CP1251
                return text.encode('cp1251').decode('utf-8')
            except:
                try:
                    # Пробуем как LATIN1
                    return text.encode('latin1').decode('utf-8')
                except:
                    # Если ничего не помогло, возвращаем как есть
                    return text
    return text

def hash_password(password):
    # Простая функция хеширования пароля
    return hashlib.sha256(password.encode()).hexdigest()