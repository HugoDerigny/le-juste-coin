from flask import Flask

import src.analyzer as Analyzer
import src.utils.CNN as CNN

app = Flask(__name__)

# Analyzer.test()
CNN.create_dataset()

@app.route('/')
def ai_test():  # put application's code here
    Analyzer.test()

    return 'OK'


if __name__ == '__main__':
    app.run()
