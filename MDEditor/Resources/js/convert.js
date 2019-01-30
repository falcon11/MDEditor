function convert(md) {
    var convert = new showdown.Converter();
    convert.setOption('tables', true);
    return convert.makeHtml(md);
}
