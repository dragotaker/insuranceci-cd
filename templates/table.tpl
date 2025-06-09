<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{table_name}}</title>
    <link rel="stylesheet" href="/static/style.css">
    <style>
        .table-condensed {
            font-size: 13px;
        }
        .table-condensed th, .table-condensed td {
            padding: 4px 6px;
            white-space: normal;
            word-break: break-word;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>{{table_name}}</h1>
        % if show_add_delete:
            <a href="/add/{{table_key}}" class="button">Добавить запись</a>
        % end
        
        <!-- Add search form -->
        <div class="search-container">
            <form action="/table/{{table_key}}" method="get" class="search-form" accept-charset="UTF-8">
                <input type="text" name="search" placeholder="Поиск..." value="{{search_query or ''}}" autocomplete="off">
                <select name="search_field">
                    <option value="">Все поля</option>
                    % for field in fields[1:]:
                        <option value="{{field}}" {{'selected' if search_field == field else ''}}>
                            {{table_info['display_fields'][field]}}
                        </option>
                    % end
                </select>
                <button type="submit" class="button">Поиск</button>
                % if search_query:
                    <a href="/table/{{table_key}}" class="button">Сбросить</a>
                % end
            </form>
        </div>
        
        <table class="table-condensed">
            <thead>
                <tr>
                    <th>№</th>
                    % for field in fields[1:]:
                        <th>{{table_info['display_fields'][field]}}</th>
                    % end
                    <th>Действия</th>
                </tr>
            </thead>
            <tbody>
                % if rows:
                    % for idx, row in enumerate(rows, 1):
                    <tr>
                            <td>{{idx}}</td>
                            % for field in fields[1:]:
                            <td>
                                % if 'display_values' in table_info and field in table_info['display_values']:
                                    {{table_info['display_values'][field].get(row[field], row[field])}}
                                % else:
                                    {{row[field]}}
                                % end
                            </td>
                        % end
                        <td>
                            <a href="/edit/{{table_key}}/{{row[fields[0]]}}" class="button">Редактировать</a>
                            % if show_add_delete:
                                <a href="/delete/{{table_key}}/{{row[fields[0]]}}" class="button delete">Удалить</a>
                            % end
                        </td>
                        </tr>
                    % end
                % else:
                    <tr>
                        <td colspan="{{len(fields) + 1}}" class="no-results">
                            % if search_query:
                                По вашему запросу ничего не найдено
                            % else:
                                В таблице пока нет данных
                            % end
                        </td>
                    </tr>
                % end
            </tbody>
        </table>
    </div>
</body>
</html> 