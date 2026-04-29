import React from 'react'
import './Navbar.css'
import logoImage from '../assets/Logo.png'

const Navbar = () => {
  return (
    <div className='navbar'>
        <div className="leftNav">
            <img src={logoImage} alt="Q-Less Logo" />
            <h1> -Less</h1>
        </div>
    </div>
  )
}

export default Navbar