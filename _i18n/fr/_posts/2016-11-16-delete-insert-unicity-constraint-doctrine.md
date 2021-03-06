---
layout: post
title: DELETE INSERT sur une contrainte d'unicité avec Doctrine
summary:
    Connaître l'origine du problème et quelles sont les solutions pour faire face à ce genre de cas.
twitter_text: DELETE INSERT sur une contrainte d'unicité avec Doctrine. Faire confiance à son domaine. %23ddd %23doctrine
tags:
 - php
 - doctrine
 - orm
 - domain driven design
 - ddd
redirect_to: /2016/11/16/delete-insert-unicity-constraint-doctrine/
---

Si vous êtes arrivé ici, c'est peut-être parce que vous avez ce message :

{% highlight bash startinline %}
SQLSTATE[23505]: Unique violation: 7 ERROR:  duplicate key value violates unique constraint "unique_picture_position_idx"
DETAIL:  Key (article_id, "position")=(41ffd17c-4a15-4074-8db0-f7f8604d3458, 0) already exists. (Doctrine\DBAL\Exception\UniqueConstraintViolationException)
{% endhighlight %}

### 1. Contexte

Imaginez un `Article` de blog avec une relation `OneToMany` vers `Picture` tout ce qu'il y a de plus classique.

{% highlight yaml startinline %}
# Article.yml

Article:
    type: entity
    [...]
    oneToMany:
        pictures:
            targetEntity: Picture
            mappedBy: article
{% endhighlight %}

{% highlight yaml startinline %}
# Picture.yml

Picture:
    type: entity
    [...]
    manyToOne:
        article:
            reversedBy: pictures
            joinColumn:
                referencedColumnName: id
                nullable: false
{% endhighlight %}

Afin de pouvoir établir un ordre entre ces images nous ajoutons une `position` à `Picture`.
Puisque nous sommes malins on ajoute une contrainte d'unicité entre cette `position` et `article_id`

{% highlight yaml startinline %}
# Picture.yml

fields:
    position:
        type: integer
        options:
            unsigned: true
    uniqueConstraints:
        unique_picture_position_idx:
            columns: [ article_id, position ]
{% endhighlight %}

### 2. Exemple

Dans cette configuration, il est possible de reproduire l'erreur.
La condition sinequanone est de procéder à un `DELETE` et un `INSERT` dans la même transaction.
Prenons l'exemple suivant :

{% highlight php startinline %}
<?php

$em->remove($picture); // $picture->position = 0
$article->getPictures()->removeElement($picture);
$picture = new Picture();
$picture->setPosition(0);
$picture->setArticle($article);
$article->getPictures()->add($picture);
$em->persist($picture);
$em->flush();
{% endhighlight %}

Bingo. Alors d'où vient le problème concrètement ?

### 3. Origine

Tout se passe dans l'`UnitOfWork` ([Doctrine\ORM\UnitOfWork](https://github.com/doctrine/doctrine2/blob/2.5/lib/Doctrine/ORM/UnitOfWork.php#L375)) de l'`ORM`.
Si on regarde d'un peu plus près la méthode `commit()` on peut constater que les `INSERT` sont fait **avant** les `DELETE` :

{% highlight php startinline %}
<?php

// Begin transaction
try {
    if ($this->entityInsertions) {
        foreach ($commitOrder as $class) {
            $this->executeInserts($class);
        }
    }

    // ...

    // Entity deletions come last and need to be in reverse commit order
    if ($this->entityDeletions) {
        for ($count = count($commitOrder), $i = $count - 1; $i >= 0 && $this->entityDeletions; --$i) {
            $this->executeDeletions($commitOrder[$i]);
        }
    }

    // Commit transaction
} catch (Exception $e) {
    // Rollback transaction
}
{% endhighlight %}

### 4. Solutions

Une première possibilité serait bien sûr d'exécuter les deux actions dans deux transactions différentes.

{% highlight php startinline %}
<?php

$em->remove($picture); // $picture->position = 0
$article->getPictures()->removeElement($picture);
$em->flush();
// ...
$picture = new Picture();
$picture->setPosition(0);
$picture->setArticle($article);
$article->getPictures()->add($picture);
$em->persist($picture);
$em->flush();
{% endhighlight %}

:bug: L'inconvénient avec cette méthode c'est si, pour une raison quelconque, l'ajout de l'image ne se passe pas bien, nous l'avons supprimé sans avoir pu la remplacer. On a donc un problème d'**incohérence des données**.

:art: Il existe une autre possibilité, c'est de **supprimer la contrainte d'unicité**.
Pourquoi ? Il est préférable de **faire confiance à son domaine** plutôt qu'à son schéma de base de données, n'en déplaise à votre esprit de DBA.

Grâce aux options de persistance en cascade et de suppression d'entité orpheline de **Doctrine** nous pouvons complètement abstraire l'utilisation de l'`EntityManager`.
De plus, une bonne habitude est d'encapsuler l'accès à vos collections dans des méthodes métier de votre agrégat :

{% highlight yaml startinline %}
# Article.yml

Article:
    type: entity
    [...]
    oneToMany:
        pictures:
            targetEntity: Picture
            mappedBy: article
            cascade: ["persist"] # Auto persist
            orphanRemoval: true  # Auto remove
{% endhighlight %}

{% highlight php startinline %}
<?php

$article->removePicture($picture);
$article->addPicture(new Picture(), 0);
$em->flush();
{% endhighlight %}

{% highlight php startinline %}
<?php

// Article.php

public function removePicture(Picture $picture)
{
    $this->pictures->removeElement($picture);
}

public function addPicture(Picture $picture, $position)
{
    foreach($this->pictures as $_picture)
    {
        if ($_picture->getPosition() === $position) {
            throw new PositionAlreadyUsed();
        }
    }

    $picture->setPosition($position);
    $this->pictures->add($picture);
}
{% endhighlight %}

Qu'en pensez-vous ? Quelle solution avez-vous choisie ? Une autre idée ?
N'hésitez pas à m'en faire part sur Twitter !