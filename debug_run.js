try {
    require('./backend/index');
} catch (e) {
    console.error('--- DEBUG ERROR START ---');
    console.error(e.message);
    console.error(e.stack);
    console.error('--- DEBUG ERROR END ---');
}
