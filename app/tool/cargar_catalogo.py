#!/usr/bin/env python3
"""Sube el catálogo de platillos a Firestore (colección options).

El catálogo vive en Firestore; este archivo solo sirve para cargarlo la
primera vez o para agregar platillos. Si un platillo ya existe, se reemplaza.

Uso (con cualquier cuenta de la app, porque las reglas piden sesión):
  python3 tool/cargar_catalogo.py correo@ejemplo.com contraseña
"""
import json
import re
import sys
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
OPTIONS = HERE.parent / "lib/firebase_options.dart"
CATALOG = HERE / "catalogo_platillos.json"


def web_config():
    text = OPTIONS.read_text()
    web = text[text.index("web = FirebaseOptions"):]
    key = re.search(r"apiKey: '([^']+)'", web).group(1)
    project = re.search(r"projectId: '([^']+)'", web).group(1)
    return key, project


def call(url, body, token=None):
    req = urllib.request.Request(url, data=json.dumps(body).encode())
    req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read() or b"{}")


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    key, project = web_config()
    login = call(
        f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={key}",
        {"email": sys.argv[1], "password": sys.argv[2], "returnSecureToken": True},
    )
    root = f"projects/{project}/databases/(default)/documents"
    writes = []
    for o in json.loads(CATALOG.read_text()):
        portions = {g: {"doubleValue": float(n)} for g, n in o["portions"].items()}
        writes.append({"update": {
            "name": f"{root}/options/{o['id']}",
            "fields": {
                "slot": {"stringValue": o["slot"]},
                "dish": {"stringValue": o["dish"]},
                "portions": {"mapValue": {"fields": portions}},
            },
        }})
    call(f"https://firestore.googleapis.com/v1/{root}:commit", {"writes": writes},
         login["idToken"])
    print(f"Catálogo cargado: {len(writes)} platillos")


if __name__ == "__main__":
    main()
