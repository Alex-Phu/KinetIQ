# KinetIQ

KinetIQ analyzes athletic movement from uploaded video using AI pose estimation, scores each joint against pro baselines, and gives you actionable drill suggestions to fix your form.

The MediaPipe pose model (`backend/pose_landmarker_heavy.task`, 30 MB) is included in this repo. If it is ever missing, the backend downloads it automatically on the first video analysis.

## Features

- Detects 13 body landmarks per frame using Google MediaPipe Pose
- Computes real joint angles (elbow, shoulder, hip, knee, trunk lean) using biomechanics math
- Scores each joint 0-100 against pro athlete reference data
- Color-coded skeleton overlay synced to video playback
- Drill suggestions ranked by your weakest detected areas
- Supports Tennis (forehand, serve) and Golf (full swing, putt)

## Requirements

- Python 3.13
- Node.js 18+

## Install

Clone the repo:

```bash
git clone https://github.com/Alex-Phu/KineticIQ.git
cd KineticIQ
```

Backend:

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

Frontend, in a second terminal:

```bash
cd frontend
npm install
npm run dev
```

Open http://localhost:3000 in your browser.

## Notes

- The backend serves on port 8000, the frontend dev server on port 3000.
- `requirements.lock.txt` pins every transitive dependency from a verified working environment. Use it if `requirements.txt` produces a broken install.
