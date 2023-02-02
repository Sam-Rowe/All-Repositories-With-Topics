# All-Repositories-With-Topics
GitHub Enterprise server can generate a CSV of all repositories, but it is missing the topics of those repos. This tool helps with that.

## Purpose

The All Repositories report is a CSV like this
```csv
created_at,owner_id,owner_type,owner_name,id,name,visibility,readable_size,raw_size,collaborators,fork?,deleted?
2023-02-01 15:48:05 +0000,5,Organization,Org1,5,repo5,private,0 Bytes,0,0,false,false
```

but what if you want the topics as well for each of those repos?
```csv
created_at,owner_id,owner_type,owner_name,id,name,visibility,readable_size,raw_size,collaborators,fork?,deleted?,topics
2023-02-01 15:49:55 +0000,5,Organization,Org1,5,repo5,private,0 Bytes,0,0,false,false,"classified,duplicate,emea,support"
```

## Usage

## Install cli tool
```bash
npm install
```

## Setup Environment vairables
Goto your user settings

![image](https://user-images.githubusercontent.com/14168597/216343581-00b26691-05aa-42f5-98c8-3abe5d60bfdb.png)

Open Developer settings at the bottom of the blade

![image](https://user-images.githubusercontent.com/14168597/216343730-ec174710-160d-4913-a3cd-a8b34d275013.png)

Then Personal access tokens

![image](https://user-images.githubusercontent.com/14168597/216343840-93ecd73b-6f51-4c39-ba7d-0f0ef43cf299.png)

Generate a new token with the following permission

![image](https://user-images.githubusercontent.com/14168597/216344133-0d3571bb-0513-4d1a-a95f-5fa2b85ce77a.png)

Then use the domain of your GHES (yeah I know badly named, I would love to review a pull request to fix this) to put into the GHES_URL
And use the PAT (Personal access token) as the GHES_TOKEN. 
For reference the commands look a bit like this, but remember to change the values.


```bash
export GHES_URL="sams-test-ghes.deneb.com"
export GHES_TOKEN="gh_tokengoeshere"
```

### Get the All Repositories report
This is generated in Stafftools on GitHub Enterprise server and looks something like this -
![image](https://user-images.githubusercontent.com/14168597/216342483-d6708b33-2add-4b5f-8a3c-acb9a063dc63.png)

## Run 
Copy the all-repositories report into the root of this repo and run the node app

```bash
node index.js all-repositories-reportnumber.csv all-repositories-with-topics.csv
```

