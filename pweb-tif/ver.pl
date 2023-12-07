#!"C:/xampp/perl/bin/perl.exe"
use strict;
use warnings;
use CGI;
use DBI;

my $cgi = CGI->new;

print "Content-type: text/html\n\n";
print <<END_HTML;
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>WikiPweb - Ver</title>
</head>
<body>
END_HTML

my $id = $cgi->param('id');

if ($id) {
    my $database = "wikipweb1";
    my $host     = "127.0.0.1";
    my $port     = 3306;
    my $user     = "root";
    my $password = "";

    my $dsn = "DBI:mysql:database=$database;host=$host;port=$port";

    my $dbh = DBI->connect($dsn, $user, $password, { PrintError => 0, RaiseError => 1 });

    if ($dbh) {
        my $sql = "SELECT titulo, contenido FROM wiki WHERE id = ?";
        my $sth = $dbh->prepare($sql);
        $sth->execute($id);

        my $row = $sth->fetchrow_hashref;

        if ($row) {
            my $titulo     = $row->{titulo};
            my $contenido  = $row->{contenido};

            $contenido =~ s/^# (.+)$/\<h1\>$1\<\/h1\>/mg;
            $contenido =~ s/^## (.+)$/\<h2\>$1\<\/h2\>/mg;
            $contenido =~ s/^###### (.+)$/\<h6\>$1\<\/h6\>/mg;
            $contenido =~ s/\*\*(.+?)\*\*/\<strong\>$1\<\/strong\>/g;
            $contenido =~ s/\*(.+?)\*/\<em\>$1\<\/em\>/g;
            $contenido =~ s/~~(.+?)~~/\<p\>$1\<\/p\>/g;
            $contenido =~ s/```(.+?)```/\<code\>$1\<\/code\>/gs;
            $contenido =~ s/\[([^\[]+?)\]\(([^\)]+?)\)/\<a href="$2"\>$1\<\/a\>/g;

            print "<h1>$titulo</h1>\n";
            print "$contenido\n";
        } else {
            print "<p>No se encontró el registro con el ID: $id</p>";
        }

        $sth->finish();
        $dbh->disconnect();
    } else {
        die "Error al conectar a la base de datos: " . DBI->errstr;
    }
} else {
    print "<p>ID no proporcionado.</p>";
}

print <<END_HTML;
</body>
</html>
END_HTML
