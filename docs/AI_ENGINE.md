# Video365 AI Engine

## 1. Overview
The AI Engine provides intelligent automation for video editing, focusing on subject tracking, rotoscoping, and semantic analysis.

## 2. Core Technologies
*   **MediaPipe (Google)**:
    *   **Face Landmarker**: Used for face tracking and Dolly Zoom effects.
    *   **Image Segmenter**: Used for one-click background removal.
    *   **Object Detector**: For identifying and tracking specific items in the frame.
*   **OpenCV (C++)**:
    *   **KLT / MOSSE Trackers**: For high-performance point and box tracking.
    *   **Optical Flow**: For mask propagation during rotoscoping.
*   **Whisper.cpp**:
    *   On-device speech-to-text for transcript-based editing and auto-captions.

## 3. Implemented AI Effects
### A. Face-Tracking Dolly
*   **Logic**: Detects the primary face in the frame.
*   **Transformation**: Calculates a `ModelView` matrix that keeps the face at a constant size and centered, simulating a dolly camera movement.
*   **Smoothing**: Uses a Kalman filter to prevent jitter.

### B. Smart Reframe
*   Analyzes the saliency map of the video and automatically crops to 9:16 while keeping the most "interesting" part of the frame visible.

## 4. On-Device Inference
All models are quantized (INT8/FP16) to run on the Android NNAPI or GPU Delegate, ensuring privacy and offline capability.
