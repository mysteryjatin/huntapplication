# OpenAI API Setup Guide for Vastu Analysis

## Overview
The Vastu AI analysis feature uses OpenAI's GPT models to provide intelligent Vastu Shastra consultations. This guide will help you set up the API key.

## Prerequisites
- OpenAI API account
- API key with access to GPT models

## Setup Steps

### 1. Get Your OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign in or create an account
3. Navigate to **API Keys** section
4. Click **Create new secret key**
5. Copy the key (you won't be able to see it again!)

### 2. Configure the .env File

1. Navigate to the Flutter project root:
   ```
   cd frontend/huntapplication/
   ```

2. Create a `.env` file if it doesn't exist:
   ```bash
   touch .env
   ```

3. Add your OpenAI API key to the `.env` file:
   ```env
   OPENAI_API_KEY=your_api_key_here
   ```

   **Example:**
   ```env
   OPENAI_API_KEY=sk-proj-abc123xyz789...
   ```

### 3. Verify Setup

The app will automatically load the API key from the `.env` file when it starts. You should see a message in the console:
```
✅ OpenAI API key loaded from .env file (length: XX)
```

If there's an error, you'll see:
```
❌ ERROR: OPENAI_API_KEY is not set in .env file
```

## API Usage & Costs

### Models Used

1. **GPT-3.5-Turbo** (Default - Text Analysis)
   - Cost: ~$0.001-0.002 per analysis
   - Speed: Fast (~2-5 seconds)
   - Use: General Vastu consultations and text-based floor plan analysis

2. **GPT-4-Vision-Preview** (Optional - Image Analysis)
   - Cost: ~$0.01-0.03 per image analysis
   - Speed: Slower (~10-15 seconds)
   - Use: Analyzing actual floor plan images

### Cost Estimation

For typical usage:
- 100 text-based analyses: ~$0.10-0.20
- 100 image analyses: ~$1.00-3.00

**Tip:** The app will automatically fall back to text-based analysis if vision API is not available or fails.

## Features

### What the AI Does

1. **Direction Setup** - Guides users to specify North direction
2. **Floor Plan Analysis** - Analyzes room placements
3. **Vastu Score** - Calculates overall compliance (0-100)
4. **Directional Analysis** - Evaluates all 8 directions
5. **Room Analysis** - Individual room scores and recommendations
6. **Remedies** - Suggests practical Vastu corrections
7. **Interactive Chat** - Answers follow-up questions

### Analysis Flow

```
User uploads floor plan
    ↓
AI shows image in chat
    ↓
User selects North direction
    ↓
AI analyzes with Vision API (or text-based fallback)
    ↓
AI provides:
  - Overall Score
  - Directional Analysis
  - Room Scores
  - Critical Issues
  - Positive Aspects
  - Recommendations
    ↓
User can ask follow-up questions
```

## Troubleshooting

### Issue: "OPENAI_API_KEY is not set"

**Solution:**
1. Verify `.env` file exists in `frontend/huntapplication/`
2. Check the key is correctly formatted: `OPENAI_API_KEY=sk-...`
3. Ensure no spaces around the `=` sign
4. Restart the app after adding the key

### Issue: "API Error: 401"

**Solution:**
- Your API key is invalid or expired
- Generate a new key from OpenAI platform
- Update the `.env` file

### Issue: "API Error: 429"

**Solution:**
- Rate limit exceeded or quota reached
- Check your OpenAI account billing
- Add credits to your account

### Issue: Vision API not working

**Solution:**
- The app automatically falls back to text-based analysis
- Vision API requires GPT-4 Vision access
- Check if your API key has vision capabilities
- Text-based analysis still provides comprehensive results

## Security Best Practices

### ⚠️ Important Security Notes

1. **Never commit `.env` file to Git**
   ```bash
   # Add to .gitignore
   .env
   ```

2. **Don't share your API key**
   - Keep it secret and secure
   - Regenerate if accidentally exposed

3. **Use environment-specific keys**
   - Development key for testing
   - Production key for live app

4. **Monitor usage**
   - Check OpenAI dashboard regularly
   - Set up usage alerts
   - Implement rate limiting if needed

## Alternative: Backend API (Recommended for Production)

For production apps, it's recommended to:

1. **Create a backend API** that handles OpenAI calls
2. **Keep API key on the server** (not in the app)
3. **Add authentication** to your backend
4. **Implement rate limiting** per user

This approach:
- ✅ Keeps API key secure
- ✅ Controls costs better
- ✅ Adds user authentication
- ✅ Enables usage analytics

## Sample Backend Structure

```
Backend Server
    ├── /api/vastu/analyze
    │   - Receives floor plan image
    │   - Calls OpenAI API
    │   - Returns analysis
    │
    ├── /api/vastu/chat
    │   - Handles chat messages
    │   - Maintains conversation history
    │   - Returns AI responses
    │
    └── Authentication & Rate Limiting
```

## Testing

To test the Vastu analysis:

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Navigate to Vastu AI Expert**

3. **Click "Scan Plan"**

4. **Upload a floor plan image**

5. **Select North direction**

6. **Wait for AI analysis** (10-15 seconds)

7. **Review results in chat**

8. **Ask follow-up questions**

## Support

If you encounter issues:

1. Check the console for error messages
2. Verify API key is correctly set
3. Check OpenAI account status
4. Review this guide
5. Contact support if needed

---

## Quick Start Checklist

- [ ] Get OpenAI API key
- [ ] Create `.env` file
- [ ] Add `OPENAI_API_KEY=your_key`
- [ ] Add `.env` to `.gitignore`
- [ ] Restart the app
- [ ] Test with a floor plan
- [ ] Monitor API usage
- [ ] Set up billing alerts

---

**Ready to go!** Your Vastu AI analysis is now powered by real artificial intelligence. 🎉



