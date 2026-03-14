# OTP SMS Template – Hunt Property App (Auto-fill ke liye)

Backend / SMS gateway pe OTP SMS ka format change karna hai taaki Android app OTP ko **automatic read karke** OTP boxes me fill kar sake.

---

## Kya change karna hai

Abhi OTP SMS aise bhej rahe ho:
```
Use OTP 521345 to log in to your Hunt property account. This OTP is valid for 5 minutes. Do not share it with anyone.
```

**Naya format (exact aisa hi hona chahiye):**

```
<#> Use OTP 521345 to log in to your Hunt property account.
1UHgxtov3VN
```

- **Pehli line:** Message jaisa abhi hai, bas **shuru me `<#>`** add karna hai. OTP number (521345) dynamic rahega.
- **Dusri line:** Sirf ye 11-character string: **`1UHgxtov3VN`** — ye app ka signature hash hai. Is line me kuch aur mat add karo (no space, no dot, no extra text).

---

## Zaroori rules

1. **Hash exact hona chahiye:** `1UHgxtov3VN` — capital/small letter, character sab same. Copy-paste karo, type mat karo.
2. **Message length:** Total SMS **140 bytes se kam** hona chahiye (normally 2 line wala message fit ho jata hai).
3. **Dusri line:** Sirf hash, uske baad koi text nahi.

---

## Kab use karna hai

Ye same format **dono** jagah use karna hai:
- **Login OTP** (jab user pehle se registered hai)
- **Signup OTP** (naye user ke liye)

Dono flows me OTP SMS ka template upar wala hi hona chahiye.

---

## Example (backend / SMS API side)

**Current (jo abhi ho sakta hai):**
```json
"message": "Use OTP {{otp}} to log in to your Hunt property account. This OTP is valid for 5 minutes."
```

**New (auto-fill ke liye):**
```text
Line 1: "<#> Use OTP {{otp}} to log in to your Hunt property account."
Line 2: "1UHgxtov3VN"
```

SMS API me agar single string bhejna ho to:
```text
"<#> Use OTP {{otp}} to log in to your Hunt property account.\n1UHgxtov3VN"
```
(`\n` = new line between line 1 and line 2)

---

## Summary

| Item        | Value |
|------------|--------|
| App hash (2nd line) | `1UHgxtov3VN` |
| 1st line prefix     | `<#>` |
| Max length          | 140 bytes |

Is format se SMS aate hi Android app OTP ko khud read karke screen pe fill kar dega; user ko type nahi karna padega.
