from flask import Flask

app = Flask(__name__)

@app.route('/')
def hifunc():
    return 'Hello, World!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=6666)

# test deployment
# test2
# test 3
# test 4
# test 5
#test 6
# test 7

# test 10
# test 11