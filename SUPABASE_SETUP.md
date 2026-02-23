# Supabase setup for Greenside HM (Jocelyn)

Follow these steps so the app has durable, synced storage for the full contract.

## 1. Create a Supabase project

- Go to [supabase.com](https://supabase.com) and create a project.
- In **Project Settings → API**, copy the **Project URL** and **anon public** key.

## 2. Configure the app

- Open `supabase/config.js`.
- Set `window.SUPABASE_URL` to your Project URL.
- Set `window.SUPABASE_ANON_KEY` to your anon key.

## 3. Run the database migration

- In the Supabase Dashboard, open **SQL Editor**.
- Copy the contents of `supabase/migrations/20250223000001_jocelyn_schema.sql`.
- Run it. This creates:
  - `profiles` (user profile + audio URLs)
  - `corpsman_logs` (MARCH-PAWS and 9-Line Medevac)
  - `training_stats` (e.g. Muay Thai streak)
  - RLS so each user only sees their own data
  - A trigger that creates a profile row when a user signs up

## 4. Create the audio storage bucket

- In the Dashboard, go to **Storage**.
- Click **New bucket**.
- Name: `jocelyn-audio`.
- Set it to **Public** if you want playback via direct URLs (recommended for “listen on any device”).
- Create the bucket. The migration already adds RLS policies on `storage.objects` so users can only upload/read/delete files in their own folder (`{user_id}/filename`).

If you did not run the migration yet, run it so the storage policies exist.

## 5. Restrict access to Jocelyn only (optional)

- To allow only one account (e.g. Jocelyn’s):
  - **Auth → Settings**: disable “Enable email signups” if you only want to invite her.
  - **Auth → Users**: invite her by email; she sets her password from the invite link.
- Alternatively, keep signup enabled and use **Auth → Policies** or app logic to restrict which emails can use the app.

## 6. Serve the app over HTTPS

- For auth and storage to work reliably, open the app over **HTTPS** (e.g. deploy to Vercel/Netlify or use a local server with HTTPS). Opening `index.html` as a file (`file://`) may block Supabase or cookies.

## 7. Password reset (Forgot Password) — URL configuration

For “Forgot Password” emails to open the app correctly, configure Supabase so it knows your app’s URL:

1. In the Supabase Dashboard, go to **Authentication → URL Configuration**.
2. **Site URL**: set this to your app’s root URL (e.g. `https://jocelyn-corpsman-app.vercel.app`).
3. **Redirect URLs**: add your reset-password page so Supabase can redirect there after the user clicks the link in the email, e.g.:
   - `https://jocelyn-corpsman-app.vercel.app/reset-password`

If you use a different host or path, use that same base URL in Site URL and add the matching `/reset-password` URL in Redirect URLs.

**Email tip:** Navy/work addresses (e.g. `@navy.mil`) often have strict spam filters and may block or delay password-reset emails. For this app, using a personal email (Gmail, Outlook, etc.) usually delivers the recovery link quickly and reliably.

---

After this, sign up or sign in in the app. MARCH-PAWS and 9-Line data sync to `corpsman_logs`, Muay Thai streak to `training_stats`, and voice memos go to the `jocelyn-audio` bucket with URLs saved in `profiles`. The **Cloud Sync** indicator in the header shows when data was last synced.
