from bottle import run
import routes

if __name__ == '__main__':
    run(host='localhost', port=8080, debug=True, reloader=True)