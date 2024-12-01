import cv2

import numpy as np

import dlib
import os
import logging
import warnings
# TensorFlow 로그 수준 설정: 0=모든 로그 표시, 1=정보 로그 생략, 2=경고만, 3=오류만
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
# oneDNN 관련 최적화 로그 비활성화
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'
# XLA 관련 로그 억제
os.environ['XLA_FLAGS'] = '--xla_gpu_cuda_data_dir='
os.environ['TF_XLA_FLAGS'] = '--tf_xla_auto_jit=0 --tf_xla_enable_xla_devices=false'
# h5py 경고 무시
warnings.filterwarnings("ignore", category=UserWarning, message="h5py is running against HDF5")
# absl 로그 수준 조정
logging.getLogger('absl').setLevel(logging.ERROR)

import tensorflow as tf  # TensorFlow를 나중에 임포트

from tensorflow.keras.models import load_model
# 학습된 모델 불러오기

model_path = r"C:\Users\imyy1\Downloads\emotion_detection_model.keras"  # 또는 실제 경로
model = load_model(model_path, compile=False)


# 감정 클래스 라벨
class_labels = ['angry', 'fear', 'happy', 'neutral', 'sad', 'surprize']


# 카메라에서 사진 촬영하기 (로컬 환경에서만 작동)
def capture_image():
    # OpenCV의 VideoCapture 객체를 이용하여 카메라에 접근
    cap = cv2.VideoCapture(0)  # '0'은 기본 카메라를 의미
    if not cap.isOpened():
        print("카메라에 접근할 수 없습니다.")
        return None

    while True:
        ret, frame = cap.read()  # 카메라에서 프레임을 읽음
        if not ret:
            print("이미지를 캡처할 수 없습니다.")
            break
         # 프레임을 좌우 반전
        frame = cv2.flip(frame, 1)
        cv2.imshow("Camera", frame)  # 실시간 영상 표시

        # 's' 키를 누르면 사진을 찍고 감정 분석 실행
        key = cv2.waitKey(1)  # 1ms 대기
        if key == ord('s'):
            captured_frame = frame.copy()  # 프레임 복사
            break
        elif key == ord('q'):  # 'q' 키를 누르면 종료
            break

    cap.release()  # 카메라 리소스를 해제
    cv2.destroyAllWindows()  # 모든 OpenCV 창 닫기
    return captured_frame

# 이미지 전처리 및 감정 분석
def analyze_emotion(image):
    print("얼굴 분석중 ..")
    # 얼굴 검출기를 사용해 얼굴 영역을 찾기
    face_detector = dlib.cnn_face_detection_model_v1("C:\\Users\\imyy1\\Downloads\\mmod_human_face_detector.dat")
    face_detections = face_detector(image, 1)

    if len(face_detections) == 0:
        print("얼굴을 찾을 수 없습니다.")
        return

    # 첫 번째 얼굴을 사용 (여러 얼굴이 있을 경우)
    left, top, right, bottom = (face_detections[0].rect.left(), face_detections[0].rect.top(),
                                face_detections[0].rect.right(), face_detections[0].rect.bottom())

    # 얼굴 영역을 자르고 전처리
    roi = image[top:bottom, left:right]
    roi = cv2.resize(roi, (48, 48))  # 모델 입력 크기에 맞게 크기 조정
    roi = roi / 255.0  # 정규화
    roi = np.expand_dims(roi, axis=0)  # 배치 차원 추가
    print("감정 분석중..")
    # 모델로 예측
    pred_probability = model.predict(roi)
    percentages = pred_probability[0] * 100

    # 감정 결과 출력
    for label, percentage in zip(class_labels, percentages):
        print(f"{label}: {percentage:.2f}%")


# 사진 촬영 후 감정 분석 실행
image = capture_image()
# 이미지 크기를 축소하여 처리 속도 향상
scale_factor = 0.5  # 50% 크기로 축소
image = cv2.resize(image, (0, 0), fx=scale_factor, fy=scale_factor)
if image is not None:

    analyze_emotion(image)  # 감정 분석 실행