import os
import subprocess

# Step 1: Set the directory
directory = r"D:\Iowa\2024 Fall\Computing_Frederick Boehmke\final paper\yang-replication materials"
os.chdir(directory)

# Step 2: Configure Git User Identity
subprocess.run(["git", "config", "--global", "user.name", "Jing Yang"])  # Replace "Your Name" with your actual name
subprocess.run(["git", "config", "--global", "user.email", "jingyoung115@gmail.com"])  # Replace with your email

# Step 3: Initialize a Git repository
subprocess.run(["git", "init"])

# Step 4: Add files to the repository
subprocess.run(["git", "add", "."])

# Step 5: Commit the files
subprocess.run(["git", "commit", "-m", "Initial commit"])

# Step 6: Link to the remote repository
subprocess.run(["git", "remote", "add", "origin", "https://github.com/jingyoung115/media-and-trust.git"])

# Step 7: Push to the remote repository
subprocess.run(["git", "push", "-u", "origin", "master"])
