<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{TABLES[table_key]['add_form_title']}}</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <div class="container">
        <h1>{{TABLES[table_key]['add_form_title']}}</h1>
        
        % if error:
        <div class="error-message">
            {{error}}
        </div>
        % end
        
        <form action="/add/{{table_key}}" method="post">
            % for field in fields[1:]:
            <div class="form-group">
                <label for="{{field}}">{{TABLES[table_key]['field_names'][field]}}</label>
                % if 'date' in field:
                    <input type="date" name="{{field}}" id="{{field}}" required>
                % elif 'email' in field:
                    <input type="email" name="{{field}}" id="{{field}}" required placeholder="example@mail.com">
                % elif 'phone' in field:
                    <input type="tel" name="{{field}}" id="{{field}}" required pattern="[+0-9 ()-]{7,}" placeholder="+7 (___) ___-__-__">
                % elif 'passport' in field:
                    <input type="text" name="{{field}}" id="{{field}}" required pattern="[A-Za-z0-9]{6,20}" placeholder="Серия и номер">
                % else:
                    <input type="text" name="{{field}}" id="{{field}}" required>
                % end
            </div>
            % end
            <button type="submit" class="button">Сохранить</button>
        </form>
    </div>
</body>
</html> 