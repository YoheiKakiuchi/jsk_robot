(ros::roseus "pepper")

(load "package://peppereus/pepper.l")
(load "package://naoqieus/naoqi-interface.l")

(defclass pepper-interface
  :super naoqi-interface
  :slots ()
  )

(defmethod pepper-interface
  (:init (&rest args)
   (send-super* :init :robot pepper-robot :naoqi-namespace "pepper_robot" args))
  (:show-image 
   (file)
   (let (ret)
     (ros::wait-for-service "show_image")
     (setq ret (instance naoqi_bridge_msgs::ShowResourceRequest :init))
     (send ret :name :data file)
     (setq res (ros::service-call "show_image" ret))
     (send res :success :data)
     ))
  (:set-show-image-folder-path 
   (name)
   (let (ret)
     (ros::wait-for-service "set_show_image_folder_path")
     (setq ret (instance naoqi_bridge_msgs::SetFolderPathRequest :init))
     (send ret :folder_path :data name)
     (setq res (ros::service-call "set_show_image_folder_path" ret))
     ))
  (:get-show-image-folder-path 
   ()
   (let (ret)
     (ros::wait-for-service "get_show_image_folder_path")
     (setq ret (instance naoqi_bridge_msgs::GetFolderPathRequest :init))
     (setq res (ros::service-call "get_show_image_folder_path" ret))
     (send res :folder_path :data)
     ))			       
  (:show-app 
   (app)
   (let (ret)
     (ros::wait-for-service "show_app")
     (setq ret (instance naoqi_bridge_msgs::ShowResourceRequest :init))
     (send ret :name :data app)
     (setq res (ros::service-call "show_app" ret))
     (send res :success :data)
     ))
  (:show-webview 
   (url) 
   (let (ret)
     (ros::wait-for-service "show_webview")
     (setq ret (instance naoqi_bridge_msgs::ShowResourceRequest :init))
     (send ret :name :data url)
     (setq res (ros::service-call "show_webview" ret))
     (send res :success :data)
     ))
  (:hide-image () (call-empty-service "hide_image"))
  )

(defmethod pepper-robot
  (:reset-pose () (send self :angle-vector #f(2 -2 -5 85 10 -70 -20 -40 85 -10  70  20  40 0 -0)))
  )

(defun pepper-init (&optional (create-viewer))
  (unless (boundp '*pepper*) (pepper))
  (unless (ros::ok) (ros::roseus "pepper_eus_interface"))
  (unless (boundp '*ri*) (setq *ri* (instance pepper-interface :init)))
  
  (ros::spin-once)
  (send *ri* :spin-once)
  
  (send *pepper* :angle-vector (send *ri* :state :potentio-vector))
  (when create-viewer (objects (list *pepper*)))
  )

#|
(setq *ri* (instance pepper-interface :init))
(setq *pepper* (pepper))
(send *pepper* :reset-pose)
(send *ri* :angle-vector (send *pepper* :angle-vector) 2000)
|#
