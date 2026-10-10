# Network — a personal CRM

A one-page app for keeping track of the people in my network: who they are, what we talked about, and when to follow up.

- **Live:** https://spencer24601.github.io/personal-crm/
- **Stack:** plain HTML/JS on GitHub Pages, with Supabase for the database and email sign-in.
- **Privacy:** the code is public, the data is not. Every row is tied to my Supabase account, and row-level security blocks everyone else, including visitors who aren't signed in. The key in `index.html` is a *publishable* key, which is designed to be public.

## Features
- Contacts with organization, role, how we met, email, phone and notes
- An interaction log for each person (date, type, summary, next step)
- Follow-up dates: overdue and due-this-week people show up first, with quick +1 week / +1 month buttons
- "Add to Google Calendar" link for any follow-up
- Search, sorting, and CSV export for backups

## Database
The schema is in `supabase/migrations/`. Tables: `crm_contacts` and `crm_interactions`.
