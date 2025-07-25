from server import app

import os
from dotenv import load_dotenv
load_dotenv()
if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=int(os.environ.get("PORT", 5000)),
        single_process=False,
    )
