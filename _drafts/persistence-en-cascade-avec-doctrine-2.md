---
layout: post
title: Persistence en cascade avec Doctrine 2
summary: Persister ses entités en cascade avec Doctrine 2
---

### OneToMany

Imaginons les deux entités suivantes:

```php
/**
 * Author
 *
 * @ORM\Table(name="author")
 * @ORM\Entity
 */
class Author
{
    /**
     * @var integer
     *
     * @ORM\Column(name="id", type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    protected $id;

    /**
     * @ORM\OneToMany(targetEntity="Book", mappedBy="author")
     */
    protected $books;

    public function __construct()
    {
        $this->books = new \Doctrine\Common\Collections\ArrayCollection;
    }

    /**
     * Get id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->id;
    }

    public function addBook(Book $book)
    {
        $this->books[] = $book;
        $book->setAuthor($this);
    }
}

/**
 * Book
 *
 * @ORM\Table(name="book")
 * @ORM\Entity
 */
class Book
{
    /**
     * @var integer
     *
     * @ORM\Column(name="id", type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    protected $id;

    /**
     * @ORM\ManyToOne(targetEntity="Author", inversedBy="books")
     * @ORM\JoinColumn(nullable=false)
     */
    protected $author;

    /**
     * Get id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->id;
    }

    public function setAuthor(Author $author)
    {
        $this->author = $author;
    }
}
```

Pour le moment un auteur peut écrire un ou plusieurs livres. Un livre a un seul auteur.
Nous avons donc une relation _OneToMany_ entre _Author_ et _Book_.

Essayons de créer un auteur et de lui associer un livre.

```php
$author = new Author;
$book = new Book;
$author->addBook($book);
$manager->persist($author);
$manager->flush();
```

Vous devriez avoir une erreur de ce type là:

```
[Doctrine\ORM\ORMInvalidArgumentException]
  A new entity was found through the relationship 'Author#books' that was not configured to cascade persist operations for
  entity: Book@0000000026085418000000011a266ab5. To solve this issue: Either explicitly call EntityManager#persist() on thi
  s unknown entity or configure cascade persist  this association in the mapping for example @ManyToOne(..,cascade={"persist"}). If you cannot find out which entity causes the problem implement 'Book#__toString()' to get a clue.
```

C'est tout à fait normal, nou avons demandé de persister _Author_ mais à aucun moment Doctrine peut savoir qu'il fallait également persister _Book_.

Pour régler ce problème, Doctrine nous propose deux solutions.

#### 1. Persister l'objet "manuellement"

Ajoutons la ligne suivante avant de persister _Author_:

```php
$manager->persist($book);
```

Cette fois-ci tout se passe correctement. C'est très bien, mais se serait préférable de pouvoir éviter d'écrire cette ligne supplémentaire. On va donc configurer notre relation pour dire à Doctrine de persister automatiquement _Book_.

#### 2. Configurer la relation

Dans le message d'erreur, Doctrine nous propose de configurer la relation grâce à `cascade={"persist"}`.
Même si la solution de la configuration peut paraître "sexy" elle n'en reste pas moins un peu "tricky" (faute de trouver mieux en français). En effet il faut bien faire attention à quel objet est persister en premier.
Dans notre cas il s'agit de Author.

```php
$manager->persist($author);
```

Il faut donc rajouter la configuration dans la classe _Author_:

```php
/**
 * @ORM\OneToMany(targetEntity="Book", mappedBy="author", cascade={"persist"})
 */
protected $books;
```

Vous ne devriez plus rencontrer d'erreur.


### ManyToMany

Allons un peu plus loin et faisons évoluer notre relation _One To Many_.
On va supposer qu'un livre peut avoir plusieurs auteurs.

Ce qui nous donne le schéma suivant:

```php
/**
 * Author
 *
 * @ORM\Table(name="author")
 * @ORM\Entity
 */
class Author
{
    /**
     * @var integer
     *
     * @ORM\Column(name="id", type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    protected $id;

    /**
     * @ORM\ManyToMany(targetEntity="Book", cascade={"persist"})
     */
    protected $books;

    public function __construct()
    {
        $this->books = new \Doctrine\Common\Collections\ArrayCollection;
    }

    /**
     * Get id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->id;
    }

    public function addBook(Book $book)
    {
        $this->books[] = $book;
    }
}

/**
 * Book
 *
 * @ORM\Table(name="book")
 * @ORM\Entity
 */
class Book
{
    /**
     * @var integer
     *
     * @ORM\Column(name="id", type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    protected $id;

    /**
     * Get id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->id;
    }
}
```

Nous sommes dans une configuration **unidirectionnelle** pour simplifier le schéma mais nous pourrions très bien la rendre **bidirectionnelle** en ajoutant la relation dans _Book_.

Ajoutons un deuxième auteur et testons:

```php
$author = new Author;
$author2 = new Author;
$book = new Book;
$author->addBook($book);
$author2->addBook($book);
$manager->persist($author);
$manager->persist($author2);
$manager->flush();
```

Normalement il n'y a aucun problème. Une nouvelle table `author_book` a fait son apparition. Elle contient deux lignes et nous montre que nous avons bien deux auteurs pour le même livre.

### OneToMany - ManyToOne

Faisons évoluer une nouvelle fois notre relation. En plus de savoir quels sont les auteurs d'un livre nous aimerions connaître la date à laquelle l'auteur a commencé à écrire sur l'ouvrage.
Pour cela nous devons forcément modifier notre table de relation pour y ajouter un nouveau champ.
A cause de celà notre table de relation va devenir une entité à part entière, c'est la seule façon de faire.

```php
/**
 * Author
 *
 * @ORM\Table(name="author")
 * @ORM\Entity
 */
class Author
{
    // ...

    /**
     * @ORM\OneToMany(targetEntity="AuthorBook", mappedBy="author", cascade={"persist"})
     */
    protected $authorBooks;

    public function __construct()
    {
        $this->authorBooks = new \Doctrine\Common\Collections\ArrayCollection;
    }

    // ...

    public function addAuthorBook(AuthorBook $authorBook)
    {
        $authorBook->setAuthor($this);
        $this->authorBooks[] = $authorBook;
    }
}

/**
 * AuthorBook
 *
 * @ORM\Table(name="author_book", uniqueConstraints={@ORM\UniqueConstraint(name="author_book_idx", columns={"author_id", "book_id"})})
 * @ORM\Entity
 */
class AuthorBook
{
    /**
     * @ORM\ManyToOne(targetEntity="Author", inversedBy="authorBooks")
     * @ORM\Id
     */
    protected $author;

    /**
     * @ORM\ManyToOne(targetEntity="Book", inversedBy="bookAuthors")
     * @ORM\Id
     */
    protected $book;

    /**
     * @ORM\Column(type="date")
     */
    protected $startedAt;

    public function __construct()
    {
        $this->startedAt = new \DateTime;
    }

    public function setAuthor(Author $author)
    {
        $this->author = $author;
    }

    public function setBook(Book $book)
    {
        $this->book = $book;
    }
}

/**
 * Book
 *
 * @ORM\Table(name="book")
 * @ORM\Entity
 */
class Book
{
    // ...

    /**
     * @ORM\OneToMany(targetEntity="AuthorBook", mappedBy="book")
     */
    protected $bookAuthors;

    public function __construct()
    {
        $this->bookAuthors = new \Doctrine\Common\Collections\ArrayCollection;
    }

    // ...

    public function addBookAuthor(AuthorBook $bookAuthor)
    {
        $bookAuthor->setBook($this);
        $this->bookAuthors[] = $bookAuthor;
    }
}
```

Tentons de populer notre base de données.

```php
$author = new Author;
$author2 = new Author;

$book = new Book;

$authorBook = new AuthorBook;

$author->addAuthorBook($authorBook);
$book->addBookAuthor($authorBook);

$authorBook2 = new AuthorBook;

$author2->addAuthorBook($authorBook2);
$book->addBookAuthor($authorBook2);

$manager->persist($author);
$manager->persist($author2);
$manager->flush();
```

Malheureusement Doctrine n'a pas l'air content:

```
[Doctrine\ORM\ORMException]
  Entity of type AuthorBook has identity through a foreign entity Author, however this entity has no identity itself. You have to call EntityManager#persist() on the related entity and make sure that an identifier was generated before trying to persist 'AuthorBook'. In case of Post Insert ID Generation (such as MySQL Auto-Increment or PostgreSQL SERIAL) this means you have to call EntityManager#flush() between both persist operations.
```

Nous y voilà, c'est exactement ce problème que j'ai rencontré et qui m'a donné <del>du fil à retordre</del> envie d'écrire ce billet.
Pourtant nous avons bien la bonne configuration grâce à `cascade={"persist"}`. Alors quel est le problème ?

C'est assez simple au final. La réponse vient du fait que la clé primaire de mon entité de liaison est composé de mes deux clés étrangères _Author_ et _Book_. Doctrine, via la configuration en cascade essaie donc de persister l'entité _AuthorBook_.
Pour celà il doit donc générer une nouvelle clé primaire. Malheureusement <i>author_id</i> n'existe pas puisque _Author_ n'a pas encore été flushé, son _id_ est donc inconnu pour Doctrine.
Comme pour la relation _OneToMany_ nous pouvons _flusher_ manuellement _Author_ et _Book_ avant mais c'est solution n'est pas adéquat dans beaucoup de situations.

Rappelez-vous, un peu plus haut j'ai dis que notre table de relation allait devenir une entité à part entière. Il suffit simplement de lui affecter un _id_ !

_AuthorBook_ devient donc:

```php
/**
 * AuthorBook
 *
 * @ORM\Table(name="author_book", uniqueConstraints={@ORM\UniqueConstraint(name="author_book_idx", columns={"author_id", "book_id"})})
 * @ORM\Entity
 */
class AuthorBook
{
    /**
     * @var integer
     *
     * @ORM\Column(name="id", type="integer")
     * @ORM\Id
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    protected $id;

    /**
     * @ORM\ManyToOne(targetEntity="Author", inversedBy="authorBooks")
     */
    protected $author;

    /**
     * @ORM\ManyToOne(targetEntity="Book", inversedBy="bookAuthors", cascade={"persist"})
     */
    protected $book;

    /**
     * @ORM\Column(type="date")
     */
    protected $startedAt;

    // ...

    /**
     * Get id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->id;
    }
}
```

Remarquez aussi le `cascade={"persist"}` sur `$book`. Et oui, en persistant _Author_, Doctrine va vouloir persister _AuthorBook_ qui lui doit persister à son tour _Book_.

Et voilà !