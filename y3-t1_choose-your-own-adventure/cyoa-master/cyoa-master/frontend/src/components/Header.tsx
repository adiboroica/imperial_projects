import { Container, Navbar } from 'react-bootstrap';
import { AiFillHome } from "react-icons/ai";
import { Link } from 'react-router-dom';

export default function Header() {
    return (
        <Navbar bg="dark" variant="dark">
            <Container>
                <Navbar.Brand href="#home">
                    <Link className="nav-link" to='/'>
                        <AiFillHome />{' '}
                        CYOA Generator
                    </Link>

                </Navbar.Brand>
            </Container>
        </Navbar>
    );
}
