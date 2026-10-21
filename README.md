# Flashback · Simple Past

Aplicación educativa de **Escuela Americana Extension** para practicar el Simple Past en inglés.
Creado por **Equipo 2**.

Hecha con Ruby on Rails 8 y Hotwire (Turbo + Stimulus). Las pantallas se actualizan en tiempo
real con WebSockets (Action Cable), sin recargar la página. La base de datos es PostgreSQL,
tanto en tu computadora como en Heroku.

## Qué hace

- **Juego individual:** cada estudiante juega a su ritmo (5 a 20 preguntas) y al final ve un repaso de sus respuestas.
- **Juego en vivo (multijugador):** la maestra crea una partida y proyecta su pantalla. Los estudiantes entran desde su celular con un código de 5 letras. La lista de jugadores, las respuestas, los resultados y el podio se actualizan solos.
- **Ranking:** puntajes de hoy, de la semana o de siempre, actualizados en vivo.
- **Administración** (`/admin`, con contraseña): agregar, editar, activar o desactivar y borrar preguntas; ver las últimas partidas; borrar puntajes.
- **Banco inicial:** 176 preguntas en 5 tipos: verbos irregulares, regular o irregular, ¿es Simple Past?, completar el espacio y corregir el error.

Puntos: 500 por respuesta correcta, más hasta 500 por rapidez.

## Publicarla en Heroku

Necesitás una cuenta de Heroku, la [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) y Git.

```bash
cd flashback
heroku login
heroku create nombre-de-tu-app
heroku addons:create heroku-postgresql:essential-0
heroku config:set ADMIN_PASSWORD=una-contraseña-segura
git push heroku main
heroku open
```

Eso es todo. En cada despliegue, Heroku:

- instala las gemas y prepara los estilos;
- corre el paso `release` del `Procfile`, que crea las tablas y carga las 176 preguntas (si ya están, no las repite);
- arranca el servidor web.

Heroku crea `DATABASE_URL` y `SECRET_KEY_BASE` por su cuenta. Si `SECRET_KEY_BASE` no aparece en
`heroku config`, crealo con `heroku config:set SECRET_KEY_BASE=$(openssl rand -hex 64)`.

**Usá un solo dyno web.** Las actualizaciones en tiempo real viven en la memoria del servidor;
con un dyno alcanza para una clase completa. Si algún día necesitás más de uno, agregá Heroku
Redis y cambiá el adaptador en `config/cable.yml`.

El área de maestra (`/admin` y "Host a live game") pide:

- usuario: `admin` (se cambia con `ADMIN_USER`)
- contraseña: la que pusiste en `ADMIN_PASSWORD`

## Probarla en tu computadora

Necesitás Ruby 3.3.6 y PostgreSQL instalado y encendido
(en Mac: `brew install postgresql@16 && brew services start postgresql@16`;
en Windows: el instalador de postgresql.org).

```bash
bundle install
bin/rails db:prepare     # crea la base de datos y carga las 176 preguntas
bin/rails server
```

Por defecto se conecta a PostgreSQL en `localhost:5432` con el usuario `postgres`.
Si tu instalación usa otro usuario o contraseña, indicalo antes de los comandos:

```bash
export PGUSER=tu_usuario PGPASSWORD=tu_contraseña
```

(o poné una URL completa en `DATABASE_URL`).

Abrí http://localhost:3000. La contraseña de maestra en tu computadora es `flashback`
(usuario `admin`), a menos que pongas otra con `ADMIN_PASSWORD`.

Para probar el modo en vivo con celulares en la misma red WiFi:
`bin/rails server -b 0.0.0.0` y abrí `http://IP-DE-TU-COMPU:3000` en el celular.

## Dónde está cada cosa

| Qué | Dónde |
|---|---|
| Tipos de pregunta y tiempos | `app/models/question.rb` |
| Reglas del juego y puntaje | `app/models/game.rb`, `app/models/participant.rb` |
| Pantallas | `app/views/` |
| Colores y estilos | `app/assets/stylesheets/application.css` |
| Temporizador y confeti | `app/javascript/controllers/` |
| Banco inicial de preguntas | `db/seeds/questions.json` |
| Configuración de Heroku | `Procfile`, `app.json`, `config/database.yml` |
