export const addItem = async (data) =>{
    try{
        let server = `${import.meta.env.VITE_SERVER_URL}/addItem`
        const response = await fetch(server,{
            method:"POST",
            credentials:"include",
            headers:{
                "Content-Type":"application/json"
            },
            body:JSON.stringify(data)
        })

        if(!response.ok){
            const res = await response.json();
            throw new Error(res.message)
        }
        const res = await response.json();
        return res

    }catch(err){
        throw err;
    }
}

export const changeStatus = async (data) =>{
    try{
        let server = `${import.meta.env.VITE_SERVER_URL}/changeStatus`
        const response = await fetch(server,{
            method:"POST",
            credentials:"include",
            headers:{
                "Content-Type":"application/json"
            },
            body:JSON.stringify(data)
        })

        if(!response.ok){
            const res = await response.json();
            throw new Error(res.message)
        }
        const res = await response.json();
        return res

    }catch(err){
        throw err;
    }
}

export const login = async (data) =>{
    try{
        let server = `${import.meta.env.VITE_SERVER_URL}/adminlogin`
        const response = await fetch(server,{
            method:"POST",
            credentials:"include",
            headers:{
                "Content-Type":"application/json"
            },
            body:JSON.stringify(data)
        })

        if(!response.ok){
            const res = await response.json();
            throw new Error(res.message)
        }
        const res = await response.json();
        return res

    }catch(err){
        throw err;
    }
}

export const kitchenStatusUpdate = async (status) =>{
    try{
        let server = `${import.meta.env.VITE_SERVER_URL}/updateKitchen`
        const response = await fetch(server,{
            method:"POST",
            credentials:"include",
            headers:{
                "Content-Type":"application/json"
            },
            body:JSON.stringify({status:status})
        })

        if(!response.ok){
            const res = await response.json();
            throw new Error(res.message)
        }
        const res = await response.json();
        return res

    }catch(err){
        throw err;
    }
}
