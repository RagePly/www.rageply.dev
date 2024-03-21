from jinja2 import Environment, FileSystemLoader, select_autoescape
from pathlib import Path
from os import mkdir
from json import load
from time import time
from sys import argv


match argv:
    case [_, p]:
        out = Path(p) 
        context = {}
    case [_, p, c]:
        out = Path(p)
        with open(c, "r") as f:
            context = json.load(f)
    case _:
        print("usage: compilehtml.py OUTDIR")
        exit(1)

env = Environment(
    loader=FileSystemLoader("./src/"),
    autoescape=select_autoescape()
)

with open("export.txt", "r") as export:
    for line in export.readlines():
        t = time()
        url = line.strip().removeprefix("/")
        dest = out / Path(url)
        ddir = dest.parent
        if not ddir.exists():
            ddir.mkdir(parents=True)

        template = env.get_template(url)
        with open(dest, "w") as dest_file:
            dest_file.write(template.render(context))
        print("rendering",url,time()-t,"s")

