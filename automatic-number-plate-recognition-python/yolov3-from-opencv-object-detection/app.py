from flask import Flask, request, jsonify
import os
import cv2
import numpy as np
import easyocr
import mysql.connector
import util
import re

app = Flask(__name__)

# Database connection
db_connection = mysql.connector.connect(
    host='localhost',
    user='root',
    password='',
    database='anpr_database'
)

# Load YOLO model
script_dir = os.path.dirname(os.path.realpath(__file__))
model_cfg_path = os.path.join(script_dir, 'model', 'cfg', 'darknet-yolov3.cfg')
model_weights_path = os.path.join(script_dir, 'model', 'weights', 'model.weights')
class_names_path = os.path.join(script_dir, 'model', 'class.names')

# Load class names
with open(class_names_path, 'r') as f:
    class_names = [j.strip() for j in f.readlines() if len(j) > 2]

# Load YOLO network
net = cv2.dnn.readNetFromDarknet(model_cfg_path, model_weights_path)

def clean_license_plate(license_plate):
    return re.sub(r'[^\w\s]', '', license_plate.replace(" ", "").strip())

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    file = request.files['image']
    img_path = os.path.join('uploads', file.filename)
    file.save(img_path)

    img = cv2.imread(img_path)
    H, W, _ = img.shape

    blob = cv2.dnn.blobFromImage(img, 1 / 255, (416, 416), (0, 0, 0), True)
    net.setInput(blob)

    detections = util.get_outputs(net)

    bboxes = []
    class_ids = []
    scores = []

    for detection in detections:
        bbox = detection[:4]
        xc, yc, w, h = bbox
        bbox = [int(xc * W), int(yc * H), int(w * W), int(h * H)]
        
        bbox_confidence = detection[4]
        class_id = np.argmax(detection[5:])
        score = np.amax(detection[5:])

        if class_id == 0:  # Assuming the license plate class ID is 0
            bboxes.append(bbox)
            class_ids.append(class_id)
            scores.append(score)

    bboxes, class_ids, scores = util.NMS(bboxes, class_ids, scores)

    reader = easyocr.Reader(['en'])
    license_plate = ""

    for bbox in bboxes:
        xc, yc, w, h = bbox
        license_plate_img = img[int(yc - (h / 2)):int(yc + (h / 2)), int(xc - (w / 2)):int(xc + (w / 2)), :].copy()
        license_plate_gray = cv2.cvtColor(license_plate_img, cv2.COLOR_BGR2GRAY)
        _, license_plate_thresh = cv2.threshold(license_plate_gray, 64, 255, cv2.THRESH_BINARY_INV)

        output = reader.readtext(license_plate_thresh)
        for out in output:
            _, text, text_score = out
            if text_score > 0.4:
                license_plate = clean_license_plate(text)
                break

    if not license_plate:
        return jsonify({"error": "No license plate detected"}), 404

    return jsonify({"license_plate": license_plate}), 200

@app.route('/check/<license_plate>', methods=['GET'])
def check_license_plate(license_plate):
    cleaned_plate = clean_license_plate(license_plate)

    cursor = db_connection.cursor(dictionary=True)
    cursor.execute("SELECT * FROM vehicle_info WHERE license_plate = %s", (cleaned_plate,))
    owner_info = cursor.fetchone()

    if owner_info:
        return jsonify({"exists": True, "owner_info": owner_info}), 200
    else:
        return jsonify({"exists": False}), 404

@app.route('/add_owner', methods=['POST'])
def add_owner():
    data = request.json
    cursor = db_connection.cursor()

    try:
        cursor.execute(""" 
            INSERT INTO vehicle_info (license_plate, owner_name, owner_address, contact_number,
                vehicle_details, vehicle_make, vehicle_model, model_year, vehicle_color)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (data['licensePlateNumber'], data['ownerName'], data['ownerAddress'],
              data['contactNumber'], data['vehicleDetails'], data['vehicleMake'],
              data['vehicleModel'], data['modelYear'], data['vehicleColor']))
        db_connection.commit()
        return jsonify({"message": "Owner details added successfully"}), 201
    except mysql.connector.Error as err:
        db_connection.rollback()
        return jsonify({"error": str(err)}), 500
    finally:
        cursor.close()

if __name__ == '__main__':
    if not os.path.exists('uploads'):
        os.makedirs('uploads')
    app.run(host='0.0.0.0', port=5000, debug=True)
