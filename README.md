# Portfolio

A personal portfolio website built with Phoenix LiveView.

## Development Setup

1. **Configure environment variables:**
   ```bash
   cp .env.example .env  # Copy the example file
   # Edit .env with your desired admin credentials
   ```

2. **Install dependencies:**
   ```bash
   mix setup
   ```

3. **Start the Phoenix server:**
   ```bash
   mix phx.server
   ```

4. **Visit [`localhost:4000`](http://localhost:4000) from your browser.**

## Admin Access

To access the admin panel for managing blogs:

1. **Set admin credentials in `.env`:**
   ```bash
   ADMIN_USERNAME=admin
   ADMIN_PASSWORD=password
   ```

2. **Visit `/admin/login` and log in with your credentials.**

   Current admin credentials (from `.env`):
   - **Username:** `admin`
   - **Password:** `password`

## Production Deployment

This app is compatible with free hosting services:

### Railway
1. Connect your GitHub repository
2. Set these environment variables:
   - `ADMIN_USERNAME=admin`
   - `ADMIN_PASSWORD=your_secure_password`
   - `DATABASE_URL=ecto://...` (Railway provides this)
   - `SECRET_KEY_BASE=$(mix phx.gen.secret)`
   - `LIVEVIEW_SIGNING_SALT=$(mix phx.gen.secret 32)`
3. Deploy automatically

### Render
1. Create a new Web Service
2. Connect your GitHub repo
3. Set build command: `mix do deps.get, compile`
4. Set start command: `mix phx.server`
5. Configure environment variables as above

### Fly.io
1. Install flyctl: `curl -L https://fly.io/install.sh | sh`
2. Run `fly launch`
3. Set secrets: `fly secrets set ADMIN_PASSWORD=your_password`

## Environment Variables

Required for production:

```bash
# Admin credentials
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_password

# Database
DATABASE_URL=ecto://username:password@host/database

# Phoenix secrets (generate with mix phx.gen.secret)
SECRET_KEY_BASE=your_secret_key_base
LIVEVIEW_SIGNING_SALT=your_signing_salt

# Optional
PHX_HOST=your-domain.com
PORT=4000
```

## Security Notes

- Never commit sensitive environment variables to version control
- Use strong, unique passwords
- Generate new secret keys for production
- Enable HTTPS in production

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
