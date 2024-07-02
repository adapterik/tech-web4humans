require.config({
    baseUrl: '/js/modules',
    catchError: true,
    onError: function (err) {
        console.error("RequireJS Error", err);
    },
});
