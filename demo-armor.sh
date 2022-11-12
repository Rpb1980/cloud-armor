export MyProject=`gcloud config get project`
export myvpc="my-vpc"
export subnet="subnet1"

gcloud services enable compute.googleapis.com

# Crete custom VPC

gcloud compute networks create ${myvpc} --project=${subnet} --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional


gcloud compute networks subnets create subnet1 --project=${MyProject} --range=10.0.0.0/24 --stack-type=IPV4_ONLY --network=${myvpc} --region=us-central1 --enable-private-ip-google-access

#Create the OWASP Juice Shop application

gcloud compute instances create-with-container owasp-juice-shop-app --container-image bkimminich/juice-shop \
     --network ${myvpc} \
     --subnet ${subnet1} \
     --machine-type e2-micro \
     --zone us-central1-a

# Set up the Cloud load balancer component: unmanaged instance group

gcloud compute instance-groups unmanaged create juice-shop-group \
    --zone=us-central1-a

# Add the Juice Shop GCE instance to the unmanaged instance group.

gcloud compute instance-groups unmanaged add-instances juice-shop-group \
    --zone=us-central1-a \
    --instances=owasp-juice-shop-app

# Set the named port to that of the Juice Shop application.

gcloud compute instance-groups unmanaged set-named-ports \
juice-shop-group \
   --named-ports=http:3000 \
   --zone=us-central1-a

# Create firewall group to allow traffic on port 3000
gcloud compute --project=${MyProject} firewall-rules create allow-traffic-on-port-3000 \
    --direction=INGRESS --priority=1000 --network=${myvpc} --action=ALLOW --rules=tcp:3000 --source-ranges=0.0.0.0/0


# Set up the Cloud load balancer component: health check

gcloud compute health-checks create tcp tcp-port-3000 \
        --port 3000

# Set up the Cloud load balancer component: backend service

gcloud compute backend-services create juice-shop-backend \
        --protocol HTTP \
        --port-name http \
        --health-checks tcp-port-3000 \
        --enable-logging \
        --global 

# Add the Juice Shop instance group to the backend service.

gcloud compute backend-services add-backend juice-shop-backend \
        --instance-group=juice-shop-group \
        --instance-group-zone=us-central1-a \
        --global

# Set up the Cloud load balancer component: URL map

gcloud compute url-maps create juice-shop-loadbalancer \
        --default-service juice-shop-backend

# Set up the Cloud load balancer component: target proxy

gcloud compute target-http-proxies create juice-shop-proxy \
        --url-map juice-shop-loadbalancer

# Set up the Cloud load balancer component: forwarding rule

gcloud compute forwarding-rules create juice-shop-rule \
        --global \
        --target-http-proxy=juice-shop-proxy \
        --ports=80
