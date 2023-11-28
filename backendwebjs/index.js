const express = require('express');
const colors = require('colors');
const cors = require('cors');

const app = express();

const routes = require('./routes/app_router');

app.use(express.json());
app.use(routes);
app.use(cors({origin:'http://10.28.1.190:3000',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
    optionsSuccessStatus: 204,
    allowedHeaders: 'Content-Type,Authorization',
  }));

app.listen(3000);
console.log(colors.rainbow('App Running'));

