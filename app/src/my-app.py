from flask import Flask

app = Flask(__name__)

@app.route('/')
def hifunc():
    return 'Hello, World!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)

    # test1
    # test2
    # test3
    # test4
    # test 5
    #  test6
    # test7
    #test 8
    # test 9
