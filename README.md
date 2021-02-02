a project that allows you to swap your amount of money  
it also saves all the swapping history, you can see it by clicking on Auti button  

how to run in terraform:  
after cloning the repository put your details in main.tr and variables.tr, also add your private_key file
to the workspace, and then run:
terraform init  
terraform apply

  
and now go to your aws console and get your instance public ip 
and you will find the app in "your-instance-ip:8000"  

how to run in k8s: 
cd k8s  
kubectl apply -f backend-dy.yml -f backend-sr.yml -f frontend-dy.yml -f frontend-sr.yml -f auti-dy.yml -f auti-sr.yml  

you will find the app in "127.0.0.1:31096" 


