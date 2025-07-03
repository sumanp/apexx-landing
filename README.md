# Apexx Steel Shaker Landing Page

This is a Sinatra-based landing page with MailerLite integration for capturing leads for the Apexx Steel Shaker early-bird campaign.

## Features

- Responsive landing page with modern design
- Lead capture form with validation
- MailerLite API integration for email marketing
- Sticky form for increased conversions
- Real-time countdown timer
- Success/error handling
- Admin stats endpoint

## Setup

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Configure environment variables:**
   Create a `.env` file with:
   ```
   MAILERLITE_API_KEY=your_mailerlite_api_key
   MAILERLITE_GROUP_ID=your_mailerlite_group_id
   WELCOME_AUTOMATION_ID=your_welcome_automation_id (optional)
   ADMIN_TOKEN=your_secure_admin_token
   ```

3. **MailerLite Setup:**
   - Get your API key from MailerLite dashboard
   - Create a group for "Apexx Early Birds"
   - (Optional) Set up a welcome automation sequence
   - Add the group ID to your environment variables

4. **Run the application:**
   ```bash
   # Development
   bundle exec rerun app.rb

   # Production
   bundle exec puma config.ru
   ```

## MailerLite Integration

The app integrates with MailerLite to:
- Add subscribers to your email list
- Assign them to a specific group
- Track custom fields (name, phone, source, discount code)
- Optionally trigger welcome email sequences

### Required MailerLite Setup:

1. **API Key**: Get from MailerLite → Integrations → Developer API
2. **Group ID**: Create a group called "Apexx Early Birds" and get the ID
3. **Custom Fields**: Create these custom fields in MailerLite:
   - `name` (Text)
   - `phone` (Text)
   - `source` (Text)
   - `signup_date` (Date)
   - `discount_code` (Text)

## Deployment

### Heroku
```bash
heroku create apexx-landing-page
heroku config:set MAILERLITE_API_KEY=your_key
heroku config:set MAILERLITE_GROUP_ID=your_group_id
git push heroku main
```

### DigitalOcean/VPS
1. Clone the repository
2. Set up environment variables
3. Install Ruby and dependencies
4. Use a reverse proxy (nginx) to serve the app
5. Set up SSL certificate

## File Structure
```
apexx-landing/
├── app.rb              # Main Sinatra application
├── config.ru           # Rack configuration
├── Gemfile             # Ruby dependencies
├── .env                # Environment variables (not in git)
├── public/
│   └── index.html      # Landing page HTML
└── README.md           # This file
```

## API Endpoints

- `GET /` - Serves the landing page
- `POST /subscribe` - Handles form submissions
- `GET /health` - Health check endpoint
- `GET /admin/stats?token=ADMIN_TOKEN` - Admin statistics

## Customization

1. **Design**: Modify the CSS in `public/index.html`
2. **Copy**: Update the text content in the HTML
3. **Email Integration**: Modify the MailerLite fields in `app.rb`
4. **Validation**: Adjust form validation rules as needed

## Security Considerations

- Always use HTTPS in production
- Keep your MailerLite API key secure
- Use environment variables for sensitive data
- Implement rate limiting for form submissions
- Consider adding CAPTCHA for spam protection

## Support

For issues or questions, contact: support@apexxgear.com
