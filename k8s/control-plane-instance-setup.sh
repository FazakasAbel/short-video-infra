sudo su -
sudo swapoff -a

touch containerd-install.sh & curl https://gist.githubusercontent.com/mrmaheshrajput/d73a30ba56ad42d09ce82429ebbc84eb/raw/a1d6d2b60799185fbe02d5ed22f4842c60b77f56/containerd-install.sh > containerd-install.sh

chmod u+x containerd-install.sh

touch k8s-install.sh & curl https://gist.githubusercontent.com/mrmaheshrajput/a9976534807406e3e0bff57b1e21733c/raw/af6a340ed734102314d6ef4a5d02e969ea2b62cb/k8s-install.sh > k8s-install.sh

chmod u+x k8s-install.sh

./containerd-install.sh

./k8s-install.sh

sudo kubeadm init 

sudo export KUBECONFIG=/etc/kubernetes/admin.conf

# Create a temporary file
tempfile=$(mktemp)
filename="/etc/containerd/config.toml"
# Use awk to process the file
awk -v line_number="$line_number" '
  NR == line_number {
    gsub(/false/, "true");
  }
  { print }
' "$filename" > "$tempfile"

# Move the temporary file to the original file
sudo mv "$tempfile" "$filename"

echo "Line $line_number updated successfully."

sudo service containerd restart
sudo service kubelet restart

kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

kubeadm token create --print-join-command >> "worker-instance-setup.sh"