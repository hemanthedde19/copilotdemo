const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.json({message: 'Hello from sample-deploy-action!'});
});

app.get('/health', (req, res) => {
  res.json({status: 'ok'});
});

module.exports = app;
