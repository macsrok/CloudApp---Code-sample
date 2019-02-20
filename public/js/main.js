$(function () {

    var spinnerHtml = '<div class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>';
    var selected = '';
    var originalHtml = $('#dropdownMenuButton').html();

    $('.dropdown-menu a').on('click', function (e) {
        e.preventDefault();
        $('#dropdownMenuButton').addClass('disabled');
        $('#dropdownMenuButton').html(spinnerHtml);
        selected = $(this).html();

        $.ajax({
            url: '/API/scrape_assets',
            data: {
                url: $('#url-input').val()
            },
            method: 'POST'
        }).done(function (data) {
            $('#dropdownMenuButton').removeClass('disabled');
            $('#dropdownMenuButton').html(selected);
            processResults(data);
        }).fail(function () {
            $('#dropdownMenuButton').removeClass('disabled');
            $('#dropdownMenuButton').html(originalHtml);
            showErrorMessage();
        });
    });

    function processResults(data) {
        var subset = data;
        var template = null;
        switch (selected) {
            case 'js':
                template = '#js-template';
                subset = extract_subset(data, 'application/javascript');
                break;
            case 'css':
                template = '#css-template';
                subset = extract_subset(data, 'text/css');
                break;
            case 'images':
                template = '#image-template';
                subset = extract_subset(data, 'image/');
                break;
            case 'audio':
                template = '#audio-template';
                subset = extract_subset(data, 'audio/mpeg');
                break;
            case 'videos':
                template = '#video-template';
                subset = extract_subset(data, 'video/mp4');
                break;
        }
        appendFragments(subset, template);
    }

    function extract_subset(data, mime) {
        var subset = [];

        $.each(data, function (i, v) {
            if (v['mime_type'].indexOf(mime) >= 0) {
                subset.push(v);
            }
        });
        return subset;
    }

    function showErrorMessage() {
        $('.alert-danger').fadeIn('fast');
        setTimeout(function () {
            $('.alert-danger').fadeOut('fast');
        }, 4000);
    }

    function appendFragments(data, template) {
        var fragments = [];
        template = template || null;
        var resetTemplate = false;
        $.each(data, function (i, v) {
            if (template === null) {
                template = determineFragmentTemplate(v);
                resetTemplate = true;
            }
            if (template !== null) {
                fragments.push(createHTMLFragment(v, template));
                if (resetTemplate === true) {
                    template = null;
                }
            }
        });

        $('.results-area').html(generateFinalMarkup(fragments));
    }

    function generateFinalMarkup(fragments) {
        if (fragments.length === 0) {
            return '<h1> No Results Found </h1>';
        }
        var markup = "<div class='row'>";
        $.each(fragments, function (i, v) {
            if (i !== 0 && i % 3 === 0) {
                markup = markup + "</div><div class='row'>";
            }
            markup = markup + v;
        });
        markup = markup + "</div>";
        return markup;

    }

    function createHTMLFragment(data, template) {
        var theTemplate = Handlebars.compile($(template).html());
        return theTemplate(data);
    }

    function determineFragmentTemplate(data) {
        var mimeType = data['mime_type'];
        var template = null;
        if (mimeType.indexOf('application/javascript') >= 0) {
            template = '#js-template';
        } else if (mimeType.indexOf('text/css') >= 0) {
            template = '#css-template';
        } else if (mimeType.indexOf('image/') >= 0) {
            template = '#image-template';
        } else if (mimeType.indexOf('audio/mpeg') >= 0) {
            template = '#audio-template';
        } else if (mimeType.indexOf('video/mp4') >= 0) {
            template = '#video-template';
        }
        return template;
    }

});