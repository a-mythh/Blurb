const dotenv = require("dotenv");
dotenv.config();

const express = require("express");
const cors = require("cors");
const { MongoClient } = require("mongodb");

const app = express();

const client = new MongoClient(process.env.MONGO_CONNECTION);
const port = process.env.PORT;

client.connect().then(() => console.log("Connected to database."));

app.use(cors());
app.use(express.json());
app.use(
	express.urlencoded({
		extended: true,
	})
);

// basic endpoint
app.get("/", async (req, res) => {
	res.send(
		"Hi! Send your query in this format {domain/search?word=[YOUR_WORD]}"
	);
});

/*
// search one
app.get("/search_one", async (req, res) => {
	try {
		if (req.query.word) {
			let word = req.query.word,
				results;
			results = await client
				.db("blurb")
				.collection("words")
				.aggregate([
					{
						$search: {
							index: "autocomplete",
							autocomplete: {
								query: word,
								path: "word",
								fuzzy: {
									maxEdits: 2,
								},
								tokenOrder: "sequential",
							},
						},
					},
					{
						$project: {
							_id: 1,
							word: 1,
							score: { $meta: "searchScore" },
						},
					},
					{
						$limit: 10,
					},
				])
				.toArray();

			return res.send(results);
		}

		res.send([]);
	} catch (error) {
		console.log(error);
		res.send([]);
	}
});
*/

// search two
app.get("/search", async (req, res) => {
	try {
		if (req.query.word) {
			let word = req.query.word;
			let results;
			results = await client
				.db("blurb")
				.collection("words")
				.aggregate([
					{
						$search: {
							index: "default",
							compound: {
								must: [
									{
										text: {
											query: word,
											path: "word",
											fuzzy: {
												maxEdits: 2,
											},
										},
									},
								],
							},
						},
					},
					{
						$project: {
							_id: 1,
							word: 1,
							score: { $meta: "searchScore" },
						},
					},
					{
						$limit: 10,
					},
				])
				.toArray();

			return res.send(results);
		}

		res.send([]);
	} catch (error) {
		console.log(error);
		res.send([]);
	}
});

app.listen(port, console.log(`Server running on port ${port}.`));
