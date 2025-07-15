const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');

const app = express();
const PORT = 5000; // Changed from 3000 to 5000

app.use(bodyParser.json());

app.post('/restart', (req, res) => {
  const repo = req.body.repository?.repo_name;
  const tag = req.body.push_data?.tag;

  if (!repo || !tag) {
    return res.status(400).send('❌ Missing repo_name or tag in payload.');
  }

  console.log(`📦 Webhook received for image: ${repo}:${tag}`);

  const cmd = `./service_restart.sh ${repo} ${tag}`;

  exec(cmd, (err, stdout, stderr) => {
    if (err) {
      console.error(`❌ Error restarting container:\n${stderr}`);
      return res.status(500).send(`Error restarting service: ${stderr}`);
    }

    console.log(`✅ Restart output:\n${stdout}`);
    res.status(200).send(`Service restarted using image ${repo}:${tag}`);
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Docker restart service listening on port ${PORT}`);
});
