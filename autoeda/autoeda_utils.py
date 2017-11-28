import json


def generate_template_option(path):
    with open(path, "r") as f:
        return json.load(f)


def package_template_option(data):
    return {data.replace(".v", ""): data}
