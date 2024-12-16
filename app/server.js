const express = require('express');
const path = require('path');
const app = express();
const port = 3000;

// Set view engine
app.set('view engine', 'ejs');

// Set absolute paths
const publicPath = path.join(__dirname, 'public');

// Serve static files with correct MIME types
app.use(express.static(publicPath, {
    setHeaders: (res, filepath) => {
        if (filepath.endsWith('.css')) {
            res.setHeader('Content-Type', 'text/css');
        }
    }
}));

// Environment-specific routes
app.get('/', (req, res) => {
    const environment = process.env.NODE_ENV || 'development';
    res.render('index', { environment });
});

// Debug route to check if CSS file exists
app.get('/debug/css', (req, res) => {
    const cssPath = path.join(publicPath, 'styles.css');
    const exists = require('fs').existsSync(cssPath);
    res.json({
        cssPath,
        exists,
        publicPath
    });
});

app.listen(port, () => {
    console.log(`Server running in ${process.env.NODE_ENV || 'development'} mode on port ${port}`);
    console.log(`Public directory: ${publicPath}`);
}); 