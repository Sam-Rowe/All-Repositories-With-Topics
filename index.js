import { Octokit } from 'octokit';
import fs from 'fs';
import csv from 'csv-parser';
import csvWriter from 'csv-write-stream';

const server = "https://" + process.env.GHES_URL + "/api/v3"


const octokit = new Octokit(
    {
        auth: process.env.GHES_TOKEN,
        baseUrl: server
    }
);

const inputCSV = process.argv[2];
const outputCSV = process.argv[3];

// if the input CSV file is not specified, exit with an error and a usage message
if (!inputCSV || !outputCSV) {
    console.error("Usage: node index.js <input CSV file> <output CSV file>");
    process.exit(1);
}

console.log("Connecting to ", server);

// using fs and csv-parser, open the all-repositories-*.csv file and read the org and repo names
// start a new CSV file called all-repositories-*-topics.csv file to write output too
// for each repo, request the topics
// write all the fields from the all-repositories-*.csv file and the topics to the all-repositories-*-topics.csv file

const results = [];
//const csvWriter = require('csv-write-stream');
const writer = csvWriter({ headers: ["created_at","owner_id","owner_type","owner_name","id","name","visibility","readable_size","raw_size","collaborators","fork?","deleted?","topics"] });
writer.pipe(fs.createWriteStream(outputCSV));

fs.createReadStream(inputCSV)
  .pipe(csv())
  .on('data', (data) => results.push(data))
  .on('end', () => {
     console.log(results);

    results.forEach((repo) => {
        octokit.request('GET /repos/{owner}/{repo}/topics', {
            owner: repo.owner_name,
            repo: repo.name
        }).then((response) => {
            // for each repo, request the topics
            console.log("Org ", repo.owner_name," Repo ", repo.name, " has the topics ", response.data.names);
            // update the CSV file with the topics
            writer.write({
                "created_at": repo.created_at,
                "owner_id": repo.owner_id,
                "owner_type": repo.owner_type,
                "owner_name": repo.owner_name,
                "id": repo.id,
                "name": repo.name,
                "visibility": repo.visibility,
                "readable_size": repo.readable_size,
                "raw_size": repo.raw_size,
                "collaborators": repo.collaborators,
                "fork?": repo['fork?'],
                "deleted?": repo['deleted?'],
                "topics": response.data.names});
         });
    });
  });


// close the CSV file
//writer.end();
