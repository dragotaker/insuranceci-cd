<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Редактировать запись - {{table_name}}</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <div class="container">
        <h1>Редактировать запись в таблице "{{table_name}}"</h1>
        
        <form action="/edit/{{table_key}}/{{row_data[id_field_name]}}" method="post">
            % for field in fields_config:
                % if field != id_field_name:
                    <div class="form-group">
                        <label for="{{field}}">{{TABLES[table_key]['field_names'][field]}}</label>
                        <input type="text" name="{{field}}" id="{{field}}" value="{{row_data[field]}}" required>
                    </div>
                % end
            % end
            <button type="submit" class="button">Сохранить</button>
        </form>
    </div>
</body>
</html> 